ifeq ($(HATCHERY-MODE),asset)


executable-flavors := $(notdir $(wildcard $(ASSET)$(system)/bin/*))

ifneq ($(BUILDERS),)

  compatible-builders := $(filter $(addsuffix :%, $(executable-flavors)), \
                                  $(BUILDERS))

  ifneq ($(compatible-builders),)
    prepare-machine := $(word 1, $(compatible-builders))
  else
    prepare-machine := $(word 1, $(BUILDERS))
  endif

  prepare-asset := $(addprefix $(ASSET)$(system)/bin/, \
                               $(word 1, $(subst :, ,$(prepare-machine))))

  prepare-machine := $(word 2, $(subst :, ,$(prepare-machine)))

else

  $(info Warning: Builder not defined for $(system) asset prepare)

  $(if $(executable-flavors), \
    $(let flavor, $(word 1, $(executable-flavors)), \
    $(let builders, $(flavor):<profile>, \
      $(info Warning: Run "$(MAKE) BUILDERS='$(builder)' $(MAKECMDGOALS)"))), \
    $(let builder, <flavor>:<profile>, \
      $(info Warning: Run "$(MAKE) BUILDERS='$(builder)' $(MAKECMDGOALS)")))

endif


$(call GENERATE-DIR, $(ASSET)$(system)/etc)

$(ASSET)$(system)/etc/%: $(module-path)prepare $(prepare-asset) \
                       | $(RUN)silk/$(prepare-machine) $(ASSET)$(system)/etc
	$(call cmd-print,  PREPARE $@)
	$(call cmd-run, $< $@ $(RUN)silk/$(prepare-machine) $(ASSET)$(system))


.NOTINTERMEDIATE: $(ASSET)$(system)/etc/%


endif
