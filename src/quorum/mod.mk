

# The top directory of the Quorum module on the hatchery computer.
#
QUORUM-SRC := $(dir $(lastword $(MAKEFILE_LIST)))


BUILDERS ?= aarch64:aws.eu-central-1.builder-aarch64.0 \
            x86_64:aws.eu-central-1.builder-x86_64.0


ifeq ($(QUORUM-BUILDER),)
  quorum-builder := \
      $(RUN)quorum-builder/$(word 2,$(subst :, ,$(word 1,$(BUILDERS))))
else
  ifneq ($(filter-out $(RUN)quorum-builder/%, \
         $(filter-out $(RUN)quorum-node/%, \
         $(QUORUM-BUILDER))),)
    quorum-builder := $(RUN)quorum-node/$(QUORUM-BUILDER)
  else
    quorum-builder := $(QUORUM-BUILDER)
  endif
endif


.PHONY: $(ASSET)quorum/all
$(ASSET)quorum/all: $(ASSET)quorum/bin.aarch64 \
                    $(ASSET)quorum/bin.x86_64 \
                    $(ASSET)quorum/network.4 \
                    $(ASSET)quorum/network.16


include $(QUORUM-SRC)builder.mk
include $(QUORUM-SRC)binary.mk
include $(QUORUM-SRC)network.mk
include $(QUORUM-SRC)node.mk


stop: clean/quorum

.PHONY: clean/quorum
clean/quorum:
	$(call cmd-clean, $(RUN)quorum-builder)
	$(call cmd-clean, $(RUN)quorum-node)
