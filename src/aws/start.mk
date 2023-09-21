define template
  $(let region, $(strip  $(1)), \
  $(let profile-path, $(strip  $(2)), \
  $(let profile-name, $(notdir $(profile-path)), \


  $(call REQUIRE-DIR, $(RUN)aws/sg.$(region).$(profile-name))

  $(call DEBUG, $(RUN)aws/sg.$(region).$(profile-name): $(profile-path))
  $(call DEBUG, 	$$(call cmd-print,  SG      $$@))
  $(call DEBUG, 	$(Q)$(AWS-SRC)find-secgroup $$@ $(region) $$<)
  $(call DEBUG,)

  $(RUN)aws/sg.$(region).$(profile-name): $(profile-path)
	$$(call cmd-print,  SG      $$@)
	$(Q)$(AWS-SRC)find-secgroup $$@ $(region) $$<


  $(call REQUIRE-DIR, $(RUN)aws/img.$(region).$(profile-name))

  $(call DEBUG, $(RUN)aws/img.$(region).$(profile-name): $(profile-path))
  $(call DEBUG, 	$$(call cmd-info,  IMG     $$@))
  $(call DEBUG, 	$$(call cmd-run, $(AWS-SRC)find-image $$@ $(region)
                           $$<))
  $(call DEBUG,)

  $(RUN)aws/img.$(region).$(profile-name): $(profile-path)
	$$(call cmd-info,  IMG     $$@)
	$$(call cmd-run, $(AWS-SRC)find-image $$@ $(region) $$<)


  $(call GENERATE-DIR, $(RUN)start)

  $(call DEBUG, $(RUN)start/aws.$(region).$(profile-name).%: \)
  $(call DEBUG, | $(RUN)aws/sg.$(region).$(profile-name) \)
  $(call DEBUG,   $(RUN)aws/img.$(region).$(profile-name) \)
  $(call DEBUG,   $(profile-path) $(AWS-COMMON-CONFIG) \)
  $(call DEBUG,   $(RUN)start)
  $(call DEBUG, 	$$(call cmd-print,  START   $$@))
  $(call DEBUG, 	$(Q)$(AWS-SRC)start $$@ $(region) \)
  $(call DEBUG,           $(RUN)aws/sg.$(region).$(profile-name) \)
  $(call DEBUG,           $(RUN)aws/img.$(region).$(profile-name) \)
  $(call DEBUG,           $(AWS-COMMON-CONFIG) $(profile-path))
  $(call DEBUG,)

  $(RUN)start/aws.$(region).$(profile-name).%: \
  | $(RUN)aws/sg.$(region).$(profile-name) \
    $(RUN)aws/img.$(region).$(profile-name) \
    $(profile-path) $(AWS-COMMON-CONFIG) \
    $(RUN)start
	$$(call cmd-print,  START   $$@)
	$(Q)$(AWS-SRC)start $$@ $(region) \
          $(RUN)aws/sg.$(region).$(profile-name) \
          $(RUN)aws/img.$(region).$(profile-name) \
          $(AWS-COMMON-CONFIG) $(profile-path)


  # Prevent `make` from being smart and deleting it automatically as it is
  # typically only used by `reach` and thus would be considered intermediate.
  #
  .NOTINTERMEDIATE: $(RUN)start/aws.$(region).$(profile-name).%

  )))
endef

$(foreach region, $(AWS-REGIONS), \
  $(foreach profile, $(AWS-PROFILES), \
    $(eval $(call template, $(region), $(profile)))))

undefine template


PHONY-COMMANDS += aws start
