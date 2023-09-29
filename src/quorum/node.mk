$(call GENERATE-DIR, $(RUN)quorum-node)

$(RUN)quorum-node/%: $(RUN)silk/% | $(RUN)quorum-node
	$(call cmd-print,  QUORUM  $@)
	$(call cmd-run, $(QUORUM-SRC)node $@ $(ASSET)quorum $<)

PHONY-COMMANDS += quorum-node

.NOTINTERMEDIATE: $(RUN)quorum-node/%
