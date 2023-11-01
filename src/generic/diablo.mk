$(call GENERATE-DIR, $(RUN)diablo/etc)

$(RUN)diablo/etc/$(system).%: $(module-path)prepare-diablo-run \
                              $(ASSET)$(system)/etc/diablo.% \
                              $(RUN)assign \
                            | $(RUN)diablo/etc
	$(call cmd-print,  PREPARE $@)
	$(call cmd-run, $< $@ $(filter-out $<, $^))

.NOTINTERMEDIATE: $(RUN)diablo/etc/$(system).%


$(call GENERATE-DIR, $(ASSET)$(system)/etc)

$(ASSET)$(system)/etc/diablo.%: $(module-path)prepare-diablo-asset \
                                $(ASSET)$(system)/etc/% \
                              | $(ASSET)$(system)/etc
	$(call cmd-print,  PREPARE $@)
	$(call cmd-run, $< $@ $(filter-out $<, $^))

.NOTINTERMEDIATE: $(ASSET)$(system)/etc/diablo.%
