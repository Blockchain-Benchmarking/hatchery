#
### Hatchery module for launching and stopping AWS machines ###
#


AWS-SRC := $(dir $(lastword $(MAKEFILE_LIST)))
AWS-NAMESPACE := $(lastword $(MAKEFILE_LIST))


include .config/aws/config.mk


$(call REQUIRE-DIR, .config/aws/config.mk)

.config/aws/config.mk:
	$(call cmd-info,  CONFIG  $@)
	$(Q)$(AWS-SRC)initialize $@



include $(AWS-SRC)start.mk
include $(AWS-SRC)stop.mk
include $(AWS-SRC)reach.mk


stop: clean/aws


.PHONY: clean/aws
clean/aws: stop/aws
	$(call cmd-clean, $(RUN)aws)
