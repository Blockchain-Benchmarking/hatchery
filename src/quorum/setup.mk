ifeq ($(HATCHERY-MODE),setup)


module-path := $(dir $(lastword $(MAKEFILE_LIST)))


servers := $(foreach i, $(shell seq 0 3), \
             $(RUN)silk/aws.eu-central-1.example.$(i))


asset := $(ASSET)quorum/etc/$(words $(servers))

ifeq ($(wildcard $(asset)),)
  $(info Error: Cannot use '$(SETUP)': missing asset '$(asset)')
  $(info Error: Run '$(MAKE) -j $(asset)')
  $(error Abort)
endif


$(call GENERATE-DIR, $(RUN))

$(RUN)assign: $(servers)
	$(call cmd-assign, $@, $(addprefix --server=,$(servers)))

$(RUN)setup: $(module-path)setup $(RUN)assign 
	$(call cmd-print,  QUORUM  $@)
	$(call cmd-run, $< $@ $(RUN)assign $(ASSET)quorum)


.PHONY: setup
setup: $(RUN)setup


stop: clean/setup

.PHONY: clean/setup
clean/setup:
	$(call cmd-clean, $(RUN)setup)


endif
