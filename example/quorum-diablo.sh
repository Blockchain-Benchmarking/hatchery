#!/bin/bash
#
#   quorum-diablo.sh - example script for launching Diablo/Quorum experiment
#
#   This scripts shows how to build required assets, deploy and launch the
#   system for benchmarking a Quorum/IBFT blockchain with the Diablo
#   benchmarking tool.
#
#   In this scripts, all the steps are done for a single run. In a real
#   benchmark, the assets would be built once, the machine launched once, many
#   systems under test would be deployed then all ran many times.
#
#   Note that assets are rebuilt unconditionally. This is the responsibility of
#   the user to decide when to rebuild the assets.
#


set -e


# Create a temporary directory to put the files which sould be written by hand.
#
workdir="$(mktemp -d --suffix='.d' "${0##*/}.XXXXXX")"
trap "rm -rf '${workdir}'" EXIT


# Setup file that contains the following information:
# - What machines to use
# - What role each machine have
# - What system to deploy
#
cat <<'EOF' > "${workdir}/setup.mk"
# Define the servers running Quorum.
#
# The '$(foreach ...)' and '$(shell ...)' syntax are regular Makefile syntax
# to perform a loop and invole external commands during the definition of
# variables.
#
# '$(RUN)' is the name of the directory where all the runtime information is
# stored.
#
# '$(RUN)silk/<machine-name>' designates a machine with the given
# '<machine-name>' with 'silk' installed as 'silk' is the only requirement to
# install Quorum.
# The '<machine-name>' starts with the name of the machine provider, in this
# case 'aws' followed by a description of how to boot the machine, here the
# aws region name 'eu-central-1' then the machine profile 'example' and finaly
# the machine unique name 'server-$(i)'.
#
servers     := $(foreach i, $(shell seq 0 3), \
                 $(RUN)silk/aws.eu-central-1.worker.server-$(i))

# Define the Diablo primary machine.
#
primary     := $(RUN)silk/aws.eu-central-1.worker.primary

# Define the Diablo secondary machines: the Diablo primary machine plus another
# dedicated secondary machine..
#
secondaries := $(RUN)silk/aws.eu-central-1.worker.primary \
               $(RUN)silk/aws.eu-central-1.worker.secondary


# Define the name of the asset required to configure the Quorum system.
# Here this is the size of the Quorum committee, computed by counting the
# number of '$(servers)'.
#
quorum-asset-name := $(words $(servers))


# Create a rule to build the role assignment file.
#
# This is done by calling the special command 'cmd-assign' with the first
# argument being the output file and the following arguments a list of machines
# prefixed by the role they should have.
#
# Note that a machine can be assigned many roles.
#
$(RUN)assign: $(servers) $(primary) $(secondaries)
	$(call cmd-assign, $@, $(addprefix --server=,    $(servers)) \
                               $(addprefix --primary=,   $(primary)) \
                               $(addprefix --secondary=, $(secondaries)))


# Add a rule to say that the final setup '$(RUN)setup' depends on the
# deployment of a Quorum system that can be benchmarked by Diablo
# '$(RUN)quorum.diablo.$(quorum-asset-name)'.
#
$(RUN)setup: $(RUN)quorum.diablo.$(quorum-asset-name)

# Also add a rule to say that the final setup '$(RUN)setup' depends on the
# deployment of a Diablo system that can be benchmark a Quorum system
# '$(RUN)diablo.quorum.$(quorum-asset-name)'.
#
$(RUN)setup: $(RUN)diablo.quorum.$(quorum-asset-name)


# The creation of the setup file itself is just the concatenation of all the
# system files created for it.
#
$(RUN)setup:
	cat $^ > $@


# Finaly create the rule to clean the setup file when stopping the whole
# system.
#
stop: clean/setup
.PHONY: clean/setup
clean/setup:
	$(call cmd-clean, $(RUN)setup)
EOF


# The AWS profile for the builder machine for aarch64 binaries.
#
cat <<EOF > "${workdir}/builder-aarch64"
types=('c7g.4xlarge' 'c6g.4xlarge')
images=('ubuntu/images/*22.04*20230516*')
secgroup='default'
disk=32
ssh_user='ubuntu'
EOF

# The AWS profile for the builder machine for x86_64 binaries.
#
cat <<EOF > "${workdir}/builder-x86_64"
types=('c6i.4xlarge' 'c6a.4xlarge')
images=('ubuntu/images/*22.04*20230516*')
secgroup='default'
disk=32
ssh_user='ubuntu'
EOF

# The AWS profile for the worker machine where to deploy either Diablo or
# Quorum.
# In practice, we could use different machines for different systems or even
# within a system but we keep it simple here.
#
cat <<EOF > "${workdir}/worker"
types=('t4g.nano' 't3.nano' 't2.nano')
images=('ubuntu/images/*22.04*20230516*')
secgroup='default'
disk=16
ssh_user='ubuntu'
EOF

aws_profiles="${workdir}/builder-aarch64"
aws_profiles="${aws_profiles} ${workdir}/builder-x86_64"
aws_profiles="${aws_profiles} ${workdir}/worker"


# Create the assets required.
# We assume that we are going to execute on two types of processors:
# - x86_64
# - aarch64
# So we start by building the binary assets for both Quorum and Diablo.
#
# We need to tell the Hatchery, for each processor architecture on which we
# want to compile the binaries, what machine should be used by putting a
# machine name in the 'BUILDERS' variable.
#
builder_aarch64='aws.eu-central-1.builder-aarch64.0'
builder_x86_64='aws.eu-central-1.builder-x86_64.0'
make -j AWS-PROFILES="${aws_profiles}" \
        BUILDERS="aarch64:${builder_aarch64} x86_64:${builder_x86_64}"  \
	asset/diablo/bin/aarch64 \
	asset/diablo/bin/x86_64  \
        asset/quorum/bin/aarch64 \
        asset/quorum/bin/x86_64


# Then we want to create the Quorum configuration files required to boot the
# system and benchmark it with Diablo.
# We still need to indicate a builder in 'BUILDERS' for this.
#
make -j AWS-PROFILES="${aws_profiles}" \
        BUILDERS="aarch64:${builder_aarch64}" \
        asset/quorum/etc/diablo.4


# Now we have prepared all the assets we need, we can turn down the builders
# we used.
#
make -j "stop/${builder_aarch64}" \
        "stop/${builder_x86_64}"


# Finally we can boot both Quorum and Diablo using the setup file that we have
# written at the beginning of this script.
#
make -j AWS-PROFILES="${aws_profiles}" SETUP="${workdir}/setup.mk" run/setup


# To launch the various systems, we first need to source the setup file we just
# built as it contains the information on how to reach each machines of a
# specific role.
#
source 'run/setup'


# We need to specify a workload so Diablo knows what to run.
# The syntax is defined by Diablo.
#
cat <<'EOF' > "${workdir}/workload.yaml"
let:
  - &endpoints
    sample: !endpoint [ ".*" ]

  - !loop &secondaries
     sample: !location [ ".*" ]

  - &account
    sample: !account { number: 1000, stake: 1000000 }

workloads:
  - number: 2
    client:
      location: *secondaries
      view: *endpoints
      behavior:
        - interaction: !transfer { from: *account, to: *account }
          load:
            0: 100
            10: 0 
EOF

silk send -t'.' "${primary}" "${workdir}/workload.yaml"


# To launch the Quorum system, we call the 'server' script on the appropriate
# quorum configuration directory.
#
silk run "${servers}" ./quorum/etc/diablo.4/server &
quorum_pid=$!

trap "kill -INT ${quorum_pid} ; rm -rf '${workdir}'" EXIT


# We then need to wait that the Quorum system boots.
# For now we do it with a wait but this could be improved by looking at the
# primary logs.
#
sleep 5

# To launch the Diablo system, we first call the 'primary' script on the
# appropriate diablo configuration directory.
#
silk run "${primary}" \
     ./diablo/etc/quorum.4/primary 'output.json' 'workload.yaml' &
primary_pid=$!

# We then need to wait that the Diablo primary waits for the secondary.
# For now we do it with a wait but this could be improved by looking at the
# primary logs.
#
sleep 5

# We now call the 'secondary' script on the appropriate diablo configuration
# directory.
#
silk run "${secondaries}" ./diablo/etc/quorum.4/secondary

# Wait that the benchmark terminates.
#
wait ${primary_pid}


# Stop all machines.
#
make -j SETUP="${workdir}/setup.mk" stop
