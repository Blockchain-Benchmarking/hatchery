#
### Hatchery module for launching and stopping AWS machines ###
#

AWS-CREDENTIALS ?= .config/aws/credentials
AWS-PROFILE-DIR ?= config/aws/
AWS-PROFILES += $(wildcard $(AWS-PROFILE-DIR)/*)
AWS-REQUEST-LIMIT ?= 2


AWS-SRC := $(dir $(lastword $(MAKEFILE_LIST)))
AWS-NAMESPACE := $(lastword $(MAKEFILE_LIST))


AWS-SEMAPHORE := $(RUN)aws/concurrency.sem

$(call REQUIRE-DIR, $(AWS-SEMAPHORE))

$(AWS-SEMAPHORE):
	$(call cmd-info,  SEM     $@)
	$(Q)echo $(AWS-REQUEST-LIMIT) > $@


AWS-REGIONS := af-south-1 \
               ap-east-1 ap-northeast-1 ap-northeast-2 ap-northeast-3 \
               ap-south-1 ap-southeast-1 ap-southeast-2 ap-southeast-3 \
               ca-central-1 \
               eu-central-1 eu-central-2 eu-north-1 eu-south-1 eu-south-2 \
               eu-west-1 eu-west-2 eu-west-3 \
               me-central-1 me-south-1 \
               sa-east-1 \
               us-east-1 us-east-2 us-west-1 us-west-2


include $(AWS-SRC)start.mk
include $(AWS-SRC)stop.mk
include $(AWS-SRC)reach.mk
