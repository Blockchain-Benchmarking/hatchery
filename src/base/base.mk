$(call GENERATE-DIR, $(RUN)base)

$(RUN)base/%: $(RUN)detect/% | $(RUN)base
	$(call cmd-print,  BASE    $@)
	$(Q)$(BASE-SRC)base $@ $<

PHONY-COMMANDS += base

.NOTINTERMEDIATE: $(RUN)base/%
