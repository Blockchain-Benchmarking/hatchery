system := quorum


module-path := $(dir $(lastword $(MAKEFILE_LIST)))
module-cache-path := $(module-path).cache/


include src/generic/build.mk
include src/generic/prepare.mk
include src/generic/system.mk


# Some scripts need a compiled version of the toolbox on the controller
# machine. These rules make the scripts depend on the compiled toolbox for this
# reason.
#
$(module-path)system: $(module-cache-path)toolbox


toolbox-deps := $(call REGULARS, $(call FIND, $(module-path)build.d/toolbox))

$(call REQUIRE-DIR, $(module-cache-path)toolbox)

$(module-cache-path)toolbox: $(module-path)build-toolbox $(toolbox-deps)
	$(call cmd-print,  BUILD   $@)
	$(call cmd-run, $<)


.PHONY: stop
stop: clean/$(system)/.cache

.PHONY: clean/$(system)/.cache

define template

  clean/$(system)/.cache:
	$$(call cmd-clean, $(module-cache-path))

endef

$(eval $(call template))

undefine template
