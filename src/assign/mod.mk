ASSIGN-SRC := $(dir $(lastword $(MAKEFILE_LIST)))


define cmd-assign
  $(call cmd-info,  ASSIGN  $(strip $(1)))
  $(call cmd-run, $(ASSIGN-SRC)assign $(1) $(2))
endef


stop: clean/assign

.PHONY: clean/assign
clean/assign:
	$(call cmd-clean, $(RUN)assign)
