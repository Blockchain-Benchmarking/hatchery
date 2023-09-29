$(call GENERATE-DIR, $(ASSET)quorum)

$(ASSET)quorum/network.%: $(quorum-builder) | $(ASSET)quorum
	$(call cmd-print,  QUORUM  $@)
	$(call cmd-run, $(QUORUM-SRC)network $@ \
                        $(patsubst $(ASSET)quorum/network.%, %, $@) $<)

.NOTINTERMEDIATE: $(ASSET)quorum/network.%
