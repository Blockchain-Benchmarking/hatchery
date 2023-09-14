# base - set a remote machine in a clean base state
#
# Perform initial preparation of a remote worker to make it easily usable by
# other modules.
#
# Commands:
#
#   base            Update the package manager index (typically `apt update`)
#
#   detect          Detect the system of a remote machine. The system is
#                   typically the package manager (e.g. `apt`, `pacman`, etc..)
#                   and write a variable `system` in the remote machine config
#                   file.
#


BASE-SRC := $(dir $(lastword $(MAKEFILE_LIST)))


include $(BASE-SRC)detect.mk
include $(BASE-SRC)base.mk


stop: clean/base


.PHONY: clean/base
clean/base:
	$(call cmd-clean, $(RUN)detect)
	$(call cmd-clean, $(RUN)base)
