$(call GENERATE-DIR, $(RUN)base)

$(RUN)base/%: $(RUN)detect/% | $(RUN)base
	$(call cmd-info,  BASE    $@)
	$(call cmd-run, $(BASE-SRC)base $@ $<)

PHONY-COMMANDS += base

.NOTINTERMEDIATE: $(RUN)base/%
