#
# WARNING: Do not use this variable in recipes! Only the last evaluation of the
#          variable is used across all modules!
#          Instead, extract the `system` name from the recipe goal or put it
#          somewhere in the recipe prerequisites and use it.
#
system := quorum


module-path := $(dir $(lastword $(MAKEFILE_LIST)))

include $(module-path)build.mk
include $(module-path)prepare.mk
