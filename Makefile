# No need for builtin rules or variables.
# It is better to be explicit about what is happening.
# Also, what we are doing here is definitely not usual and there is no builtin
# that could help us.
#
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Do not print useless information, there is already way enough to process on
# standard output.
#
MAKEFLAGS += --no-print-directory


# If there is any user specific rules / variables, take them from the `.config`
# directory.
#
include .config/Makefile


# The default rule must be placed after the potential inclusion of user
# specific rule in case it has to be overriden but before the inclusion of
# every other rules.
#
default: help
.PHONY: default


include function.mk
include command.mk


# Define the directory that is reserved for storing precomputed data and
# experimental results.
# User can redefine this location on the command line.
#
ASSET ?= asset/


# Define the directory that is reserved for runtime information.
# This directory is used by additional module rules.
#
RUN := run/

# This phony command is to stop any machine that is running.
# Packages defining rules to stop machines can register their stopping rules
# as a dependency of `stop`.
#
.PHONY: stop
stop:
	$(if $(wildcard $(RUN)start), $(call cmd-rmdir, $(RUN)start))
	$(call cmd-clean, $(RUN)reach)
	$(if $(wildcard $(RUN)), $(call cmd-rmdir, $(RUN)))


$(if $(wildcard .config/Makefile), , $(eval .NOTPARALLEL:))

$(call REQUIRE-DIR, .config/Makefile)

.config/Makefile:
	$(call cmd-info,  CONFIG  $@)
	$(Q)./src/initialize $@ src


# The Hatchery runs in two modes:
#
# + asset  Produces assets with a relatively small number of machines. This can
#          be done once and then the assets are used for many experiments.
#
# + setup  Create experimental setups, possibly from already built assets.
#          No asset can be build in this mode.
#
ifeq ($(filter $(ASSET)%, $(MAKECMDGOALS)),$(MAKECMDGOALS))
  HATCHERY-MODE := asset
else
  ifeq ($(filter $(ASSET)%, $(MAKECMDGOALS)),)
    HATCHERY-MODE := setup
  else
    HATCHERY-MODE := mixed
  endif
endif

# Running the Hatchery to produce assets and create setups at the same time
# is forbidden.
#
ifeq ($(HATCHERY-MODE),mixed)
  $(info Error: Attempt to run in mixed mode)
  $(info Error: Please process in two steps:)
  $(info Error: - '$(MAKE) -j $(filter $(ASSET)%, $(MAKECMDGOALS))')
  $(info Error: - '$(MAKE) -j $(filter-out $(ASSET)%, $(MAKECMDGOALS))')
  $(error Abort)
endif


# This is where we include additional rules / variables.
#
$(foreach module, $(addsuffix /mod.mk, $(MODULES)), \
  $(if $(wildcard $(module)), \
    $(eval include $(module))))


# Packages can define some words as "phony commands" by adding them to the
# `PHONY-COMMANDS` variable.
#
# The consequence is that if a user explicitely indicates a target starting by
# this word, it is automatically prefixed by `$(RUN)`.
#
# This enable the user to type e.g. `make start/something` without having to
# care about the value of `$(RUN)`.
#
define template
  $(let goal, $(strip $(1)), \

  $(call DEBUG, $(goal): $(RUN)$(goal))
  $(call DEBUG,)

  .PHONY: $(goal)
  $(goal): $(RUN)$(goal)

  )
endef

$(if $(RUN), \
  $(foreach cmd, $(sort $(PHONY-COMMANDS)), \
    $(foreach goal, $(filter $(cmd)/%, $(MAKECMDGOALS)), \
      $(eval $(call template, $(goal))))))

undefine template


.PHONY: help
help:
	@echo 'Hatchery - launch, configure and manage machines in large scale deployments'
	@echo ''
	@echo 'Create large scale distributed test environments by launching and stopping'
	@echo 'remote machines from different cloud providers and configuring them to run as'
	@echo 'a distributed system.'
	@echo ''
	@echo 'Syntax: make [-j] <command>/<specification>...'
	@echo ''
	@echo 'Commands:'
	@echo ''
	@echo '  help    print this message'
	@echo ''
	@echo '  reach   wait for a machine to have a reachable IP'
	@echo ''
	@echo '  start   start a machine'
	@echo ''
	@echo '  stop    stop one or more machines'
	@echo ''
	@echo 'Examples:'
	@echo ''
	@echo '  make -j reach/aws.us-west-1.example.{0,1,2,3}'
	@echo '    Start 4 AWS machines with the `example` profile on region `us-west-1` and'
	@echo '    wait for them to have a reachable IP.'
	@echo ''
	@echo '  make -j stop/aws'
	@echo '    Stop all managed AWS machines.'
	@echo ''
