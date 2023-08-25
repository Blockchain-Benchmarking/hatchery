$(call GENERATE-DIR, $(RUN)reach)

$(RUN)reach/aws.%: $(RUN)start/aws.% | $(AWS-SEMAPHORE) $(RUN)reach
	$(call cmd-print,  REACH   $@)
	$(Q)$(AWS-SRC)reach $@ $(AWS-SEMAPHORE) $<

PHONY-COMMANDS += reach
