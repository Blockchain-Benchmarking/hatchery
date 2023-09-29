$(call GENERATE-DIR, $(RUN)quorum-builder)

$(RUN)quorum-builder/%: $(RUN)silk/% | $(RUN)quorum-builder
	$(call cmd-print,  QUORUM  $@)
	$(call cmd-run, $(QUORUM-SRC)builder $@ $<)

PHONY-COMMANDS += quorum-builder

.NOTINTERMEDIATE: $(RUN)quorum-builder/%
