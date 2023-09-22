# silk - install silk on remote machines
#
# Download, compile and install the last version (or a specified version) of
# Silk on a remote machine and set approprivate kv based on the machine shell
# config file.
#
# Commands:
#
#   silk            Install and configure silk.
#


SILK-SRC := $(dir $(lastword $(MAKEFILE_LIST)))


include .config/silk/config.mk


$(call REQUIRE-DIR, .config/silk/config.mk)

.config/silk/config.mk:
	$(call cmd-info,  CONFIG  $@)
	$(Q)$(SILK-SRC)initialize $@


$(call GENERATE-DIR, $(RUN)silk)

$(RUN)silk/%: $(RUN)base/% | $(RUN)silk
	$(call cmd-info,  SILK    $@)
	$(call cmd-run, $(SILK-SRC)silk '$(SILK_URL)' '$(SILK_COMMIT)' \
                        $(SILK_PORT) $@ $<)

PHONY-COMMANDS += silk

.NOTINTERMEDIATE: $(RUN)silk/%


stop: clean/silk


.PHONY: clean/silk
clean/silk:
	$(call cmd-clean, $(RUN)silk)
