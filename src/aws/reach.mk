$(call GENERATE-DIR, $(RUN)reach)

$(RUN)reach/aws.%: $(RUN)start/aws.% | $(RUN)reach
	$(call cmd-print,  REACH   $@)
	$(Q)$(AWS-SRC)reach $@ $<

PHONY-COMMANDS += reach
