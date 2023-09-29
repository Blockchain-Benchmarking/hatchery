define template
  $(let builder-config, $(strip $(1)), \
  $(let arch, $(word 1,$(subst :, ,$(builder-config))), \
  $(let builder, $(word 2,$(subst :, ,$(builder-config))), \


  $(call GENERATE-DIR, $(ASSET)quorum)

  $(ASSET)quorum/bin.$(arch): $(RUN)quorum-builder/$(builder) \
                              | $(ASSET)quorum
	$$(call cmd-print,  QUORUM  $$@)
	$$(call cmd-run, $(QUORUM-SRC)binary $$@ $$<)


  )))

  .NOTINTERMEDIATE: $(ASSET)quorum/bin.$(arch)
endef

$(foreach builder-config, $(BUILDERS), \
  $(eval $(call template, $(builder-config))))

undefine template
