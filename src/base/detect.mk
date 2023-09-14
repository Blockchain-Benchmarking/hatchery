$(call GENERATE-DIR, $(RUN)detect)

$(RUN)detect/%: $(RUN)reach/% | $(RUN)detect
	$(call cmd-print,  DETECT  $@)
	$(Q)$(BASE-SRC)detect $@ $<

PHONY-COMMANDS += detect

.NOTINTERMEDIATE: $(RUN)detect/%
