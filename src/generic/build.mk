builder-dependencies := $(call REGULARS, $(call FIND, $(module-path)build.d))


define template
  $(let builder, $(strip $(1)), \
  $(let flavor,  $(word 1,$(subst :, ,$(builder))), \
  $(let machine, $(word 2,$(subst :, ,$(builder))), \


  $(call REQUIRE-DIR, $(ASSET)$(system)/bin/$(flavor))

  $(ASSET)$(system)/bin/$(flavor): $(module-path)build \
                                   $(RUN)silk/$(machine) \
                                   $(builder-dependencies) \
                                 | $(RUN)base/$(machine)
	$$(call cmd-print,  BUILD   $$@)
	$$(call cmd-run, $$< $$@ $$(RUN)silk/$(machine))


  .NOTINTERMEDIATE: $(ASSET)$(system)/bin/$(flavor)


  )))
endef

$(foreach builder, $(BUILDERS), \
  $(eval $(call template, $(builder))))

undefine template
