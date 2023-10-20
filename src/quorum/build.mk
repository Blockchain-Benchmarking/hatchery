ifeq ($(HATCHERY-MODE),asset)


builder-dependencies := $(call REGULARS, $(call FIND, $(module-path)build.d))


define template
  $(let builder-config, $(strip $(1)), \
  $(let flavor,  $(word 1,$(subst :, ,$(builder-config))), \
  $(let builder, $(word 2,$(subst :, ,$(builder-config))), \


  $(call GENERATE-DIR, $(ASSET)$(system)/bin)

  $(ASSET)$(system)/bin/$(flavor): $(module-path)build \
                                   $(builder-dependencies) \
                                 | $(RUN)silk/$(builder) $(ASSET)$(system)/bin
	$$(call cmd-print,  BUILD   $$@)
	$$(call cmd-run, $$< $$@ $$(RUN)silk/$(builder))


  .NOTINTERMEDIATE: $(ASSET)$(system)/bin/$(flavor)


  )))
endef

$(foreach builder-config, $(BUILDERS), \
  $(eval $(call template, $(builder-config))))

undefine template


missing-asset-rules := $(filter-out \
   $(foreach builder-config, $(BUILDERS), \
     $(addprefix $(ASSET)$(system)/bin/, \
     $(word 1,$(subst :, ,$(builder-config))))), \
   $(filter $(ASSET)$(system)/bin/%, $(MAKECMDGOALS)))

ifneq ($(missing-asset-rules),)
  missing-flavors := \
     $(sort $(patsubst $(ASSET)$(system)/bin/%, %, $(missing-asset-rules)))
  builders := \
     $(patsubst %,%:<profile>,$(missing-flavors))

  $(info Error: Builder not defined for assets:)
  $(foreach asset, $(missing-asset-rules), $(info Error:   - $(asset)))
  $(info Error: Run "$(MAKE) BUILDERS='$(builders)' $(missing-asset-rules)")
  $(error Abort)
endif


endif
