stop: stop/extern


.PHONY: stop/extern
stop/extern:


extern-running-machines := $(wildcard $(RUN)start/extern.*)

define template
  $(let machine-path, $(strip $(1)), \
  $(let machine-name, $(strip $(patsubst $(RUN)start/%, %, $(machine-path))), \


  stop/extern: stop/$(machine-name)


  .PHONY: stop/$(machine-name)
  stop/$(machine-name):
	$$(call cmd-print,  STOP    $(machine-path))
	$$(call cmd-run, rm $(machine-path))

  ))
endef

$(foreach machine, $(extern-running-machines), \
  $(eval $(call template, $(machine))))

undefine template
