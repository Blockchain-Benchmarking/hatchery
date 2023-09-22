# extern - using extern remote machines
#
# Use extern remote machine which are provisoned by other tools than the
# Hatchery.
#
# Commands:
#
#   start/extern.<profile>  Create a machine config for the given profile
#
#   stop/extern.<profile>   Delete the config for the given extern machine
#
#   reach/extern.<profile>  Reach the machine for the given profile by ssh
#


EXTERN-SRC := $(dir $(lastword $(MAKEFILE_LIST)))


include .config/extern/config.mk


$(call REQUIRE-DIR, .config/extern/config.mk)

.config/extern/config.mk:
	$(call cmd-info,  CONFIG  $@)
	$(Q)$(EXTERN-SRC)initialize $@


include $(EXTERN-SRC)start.mk
include $(EXTERN-SRC)stop.mk
include $(EXTERN-SRC)reach.mk
