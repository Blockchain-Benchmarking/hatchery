$(call GENERATE-DIR, $(RUN))


define template

  $$(RUN)$(system).%: $(module-path)system \
                      $$(ASSET)$(system)/etc/% \
                      $$(RUN)assign \
                    | $$(RUN)
	  $$(call cmd-print,  SYSTEM  $$@)
	  $$(call cmd-run, $$< $$@ $$(filter-out $$<, $$^) $$(ASSET)$(system))

endef

$(eval $(call template))

undefine template


define template

  $$(RUN)$(system).%: $$(module-path)system \
                      $$(RUN)$(system)/etc/% \
                      $$(RUN)assign \
                    | $$(RUN)
	$$(call cmd-print,  SYSTEM  $$@)
	$$(call cmd-run, $$< $$@ $$(filter-out $$<, $$^) $$(ASSET)$(system))

endef

$(eval $(call template))

undefine template



stop: clean/$(system)

.PHONY: clean/$(system)
clean/$(system):
	$(call cmd-clean, $(wildcard $(subst clean/,$(RUN),$@).*))
	$(call cmd-clean, $(subst clean/,$(RUN),$@))
