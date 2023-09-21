$(call GENERATE-DIR, $(RUN)reach)

$(RUN)reach/aws.%: $(RUN)start/aws.% | $(RUN)reach
	$(call cmd-info,  REACH   $@)
	$(call cmd-run, $(AWS-SRC)reach $@ $<)

PHONY-COMMANDS += reach

.NOTINTERMEDIATE: $(RUN)reach/aws.%
