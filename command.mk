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
  $(Q)./src/capture --show-stdout=never --show-stderr=onfail $(1)
endef
