# This piece of code is to select the best machine to prepare the config asset.
#
# If there is already an existing binary asset for a given flavor and that
# there is a machine with this flavor listed in BUILDERS then use this machine.
#
# Otherwise if BUILDERS is not empty then use the first machine found in
# BUILDERS.
#
# If BUILDERS is empty, use an impossible machine to abort the building
# process.

existing-bin-flavors := $(notdir $(wildcard $(ASSET)$(system)/bin/*))

ifneq ($(BUILDERS),)

  compatible-builders  := $(filter $(addsuffix :%, $(existing-bin-flavors)), \
                                   $(BUILDERS))

  ifneq ($(compatible-builders),)
    prepare-builder := $(word 1, $(compatible-builders))
  else
    prepare-builder := $(word 1, $(BUILDERS))
  endif

  prepare-machine := $(RUN)silk/$(word 2, $(subst :, ,$(prepare-builder)))
  prepare-flavor  := $(word 1, $(subst :, ,$(prepare-builder)))
  prepare-binary  := $(ASSET)$(system)/bin/$(prepare-flavor)

else

  prepare-machine := ABORT-BUILDERS-NOT-DEFINED
  prepare-binary  := ABORT-BUILDERS-NOT-DEFINED

endif


# This rule builds a config asset for the current system.
# It requires a `prepare` script taking three arguments:
# - path of the output config asset
# - path of the shell config of the machine to use to prepare the asset
# - path of the binary asset to install on the machine

$(ASSET)$(system)/etc/%: $(module-path)prepare \
                         $(prepare-machine) \
                         $(prepare-binary) \
                       | $(ASSET)$(system)/etc
	$(call cmd-print,  PREPARE $@)
	$(call cmd-run, $< $@ $(filter-out $<, $^))


.NOTINTERMEDIATE: $(ASSET)$(system)/etc/%
