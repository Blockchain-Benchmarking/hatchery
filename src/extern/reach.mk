$(call GENERATE-DIR, $(RUN)reach)

$(RUN)reach/extern.%: $(RUN)start/extern.% | $(RUN)reach
	$(call cmd-info,  REACH   $@)
	$(call cmd-run, cp $< $@)

PHONY-COMMANDS += reach

.NOTINTERMEDIATE: $(RUN)reach/extern.%
