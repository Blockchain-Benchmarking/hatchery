$(call GENERATE-DIR, $(RUN)detect)

$(RUN)detect/%: $(RUN)reach/% | $(RUN)detect
	$(call cmd-info,  DETECT  $@)
	$(call cmd-run, $(BASE-SRC)detect $@ $<)

PHONY-COMMANDS += detect

.NOTINTERMEDIATE: $(RUN)detect/%
