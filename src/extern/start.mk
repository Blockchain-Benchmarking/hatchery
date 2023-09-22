define template
  $(let profile-path, $(strip  $(1)), \
  $(let profile-name, $(notdir $(profile-path)), \

  $(RUN)start/extern.$(profile-name): $(profile-path) | $(RUN)start
	$$(call cmd-print,  START   $$@)
	$$(call cmd-run, $(EXTERN-SRC)start $$@ $(profile-path))

  .NOTINTERMEDIATE: $(RUN)start/extern.$(profile-name)

  ))
endef

$(foreach profile, $(EXTERN-PROFILES), \
  $(eval $(call template, $(profile))))

undefine template

PHONY-COMMANDS += start
