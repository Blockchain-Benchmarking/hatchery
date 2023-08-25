$(AWS-NAMESPACE)-running-machines := $(wildcard $(RUN)start/aws.*)


define __region-of-machine
  $(let base, $(basename $(1)), \
  $(let concat, $(strip $(2)), \
    $(if $(filter-out $(base), $(1)), \
      $(call __region-of-machine, $(base), $(suffix $(1))), \
      $(base)$(concat))))
endef

define region-of-machine
$(strip
  $(foreach machine, $(1), \
    $(call __region-of-machine, $(machine))))
endef


$(AWS-NAMESPACE)-running-regions := $(sort \
  $(call region-of-machine, $($(AWS-NAMESPACE)-running-machines)))


define template

  $(call DEBUG, stop: stop/aws)
  $(call DEBUG,)

  stop: stop/aws


  $(call DEBUG, stop/aws:)
  $(call DEBUG,)

  stop/aws:

endef

$(if $($(AWS-NAMESPACE)-running-machines), \
  $(eval $(call template)))


define template
  $(let region-path, $(strip $(1)), \
  $(let region-name, $(strip $(patsubst $(RUN)start/%, %, $(region-path))), \


  $(call DEBUG, stop/aws: stop/$(region-name))
  $(call DEBUG,)

  stop/aws: stop/$(region-name)


  $(call DEBUG, stop/$(region-name):)
  $(call DEBUG,)

  stop/$(region-name):

  ))
endef

$(foreach region, $($(AWS-NAMESPACE)-running-regions), \
  $(eval $(call template, $(region))))

undefine template


define template
  $(let machine-path, $(strip $(1)), \
  $(let machine-name, $(strip $(patsubst $(RUN)start/%, %, $(machine-path))), \
  $(let region-name, $(call region-of-machine, $(machine-name)), \


  $(call DEBUG, stop/$(region-name): stop/$(machine-name))
  $(call DEBUG,)

  stop/$(region-name): stop/$(machine-name)



  $(call DEBUG, stop/$(machine-name): | $(AWS-SEMAPHORE))
  $(call DEBUG, 	$$(call cmd-print,  STOP    $(machine-path)))
  $(call DEBUG, 	$(Q)$(AWS-SRC)stop $(AWS-SEMAPHORE) $(machine-path))
  $(call DEBUG,)

  stop/$(machine-name): | $(AWS-SEMAPHORE)
	$$(call cmd-print,  STOP    $(machine-path))
	$(Q)$(AWS-SRC)stop $(AWS-SEMAPHORE) $(machine-path)

  )))
endef

$(foreach machine, $($(AWS-NAMESPACE)-running-machines), \
  $(eval $(call template, $(machine))))

undefine template


undefine region-of-machine
undefine __region-of-machine
