define cmd-mkdir
  $(call cmd-info,  MKDIR   $(strip $(1)))
  $(Q)mkdir $(1)
endef

define cmd-clean
  $(call cmd-info,  CLEAN   $(strip $(1)))
  $(Q)rm -rf $(1) || true 2> '/dev/null'
endef

define cmd-rmdir
  $(call cmd-info,  RMDIR   $(strip $(1)))
  $(Q)rmdir $(1)
endef

define cmd-run
  $(call cmd-print,  RUN     $(strip $(notdir $(1))) $(firstword $(2)))
  $(Q)$(strip $(1)) $(2)
endef
