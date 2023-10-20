VERBOSE ?= 1
V       ?= $(VERBOSE)

# Levels of verbosity :
# V  = 0 --> only warnings and errors are printed
# V  = 1 --> pretty print important commands
# V  = 2 --> pretty print all commands
# V  = 3 --> print every commands as they are executed
# V >= 4 --> print every commands and generated rules
ifeq ($(V),0)
  Q := @
endif
ifeq ($(V),1)
  Q := @
  define cmd-print
    @echo '$(1)'
  endef
endif
ifeq ($(V),2)
  Q := @
  define cmd-print
    @echo '$(1)'
  endef
  define cmd-info
    @echo '$(1)'
  endef
endif
ifeq ($(V),3)
  define cmd-run
    $(Q)$(1)
  endef
else
  define cmd-run
    $(Q)./src/capture --show-stdout=never --show-stderr=onfail $(1)
  endef
endif
ifneq ($(filter-out 0 1 2 3, $(V)),)
  define DEBUG
    $(info $(1))
  endef
endif


# Useful custom makefile commands

# Remove all the trailing slashes of the words in the first argument.
define NOSLASH
  $(if $(filter %/, $(1)),                     \
     $(call NOSLASH, $(patsubst %/, %, $(1))), \
     $(1))
endef

define SHIFT
  $(wordlist 2, $(words $(1)), $(1))
endef


define __FIND
  $(1) $(foreach e, $(1), \
    $(call FIND, $(wildcard $(strip $(e))/*)))
endef

define FIND
  $(if $(1), $(strip $(call __FIND, $(call NOSLASH, $(1)))))
endef


define EXISTS
  $(strip $(wildcard $(1)))
endef

define DIRECTORIES
  $(strip $(patsubst %/, %, $(filter %/, $(wildcard $(addsuffix /,$(1))))))
endef

define REGULARS
  $(filter-out $(call DIRECTORIES, $(1)), $(1))
endef


define __FILTER-DIR
  $(strip $(call NOSLASH, \
    $(filter $(strip $(call NOSLASH, $(1)))/, \
             $(wildcard $(strip $(call NOSLASH, $(1)))/))))
endef

define FILTER-DIR
$(strip $(foreach path, $(1), $(call __FILTER-DIR, $(path))))
endef


define __FILTER-OUT-DIR
  $(strip $(call NOSLASH, \
    $(filter-out $(strip $(call NOSLASH, $(1)))/, \
                 $(wildcard $(strip $(call NOSLASH, $(1)))/))))
endef

define FILTER-OUT-DIR
$(strip $(foreach path, $(1), $(call __FILTER-OUT-DIR, $(path))))
endef


_JOIN_EMPTY :=
_JOIN_SPACE := $(_JOIN_EMPTY) $(_JOIN_EMPTY)

define JOIN
$(subst $(_JOIN_SPACE),$(strip $(1)),$(strip $(2)))
endef


define REVERSE
  $(strip $(if $(strip $(1)), \
    $(call REVERSE, $(wordlist 2, $(words $(1)), \
                    $(1)), $(firstword $(1)) $(2)), \
    $(2)))
endef


# Autodirectory generation
# Simply do $(call REQUIRE-DIR, <some-dir>) to generate rules to create
# all the directory hierarchy.

# Variable to store for which directories the rules are already been generated.
__AUTODIR-DONE := .

# Variable to indicate to not generate a recipe to.
__AUTODIR-NORECIPE :=

# Create a rule for generating the directory specified as first argument and
# if necessary, generate recursively rules for parent directories until
# reaching .
define __AUTODIR-RULE-RECIPE
  $(call DEBUG, $(strip $(1)): | $(strip $(call NOSLASH, $(dir $(1)))))
  $(call DEBUG,         $$(call cmd-mkdir, $$@))
  $(call DEBUG)

  __AUTODIR-DONE += $(1)

  $(1): | $(call NOSLASH, $(dir $(1)))
	$$(call cmd-mkdir, $$@)

  $(if $(filter-out $(__AUTODIR-DONE), $(call NOSLASH, $(dir $(1)))), \
    $(call __AUTODIR-RULE, $(call NOSLASH, $(dir $(1)))))
endef

define __AUTODIR-RULE-NORECIPE
  $(call DEBUG, $(strip $(1)): $(strip $(call NOSLASH, $(dir $(1)))))
  $(call DEBUG)

  __AUTODIR-DONE += $(1)

  $(1): | $(call NOSLASH, $(dir $(1)))

  $(if $(filter-out $(__AUTODIR-DONE), $(call NOSLASH, $(dir $(1)))), \
    $(call __AUTODIR-RULE, $(call NOSLASH, $(dir $(1)))))
endef

define __AUTODIR-RULE
  $(if $(filter-out $(__AUTODIR-NORECIPE), $(1)), \
    $(eval $(call __AUTODIR-RULE-RECIPE, $(1))),  \
    $(eval $(call __AUTODIR-RULE-NORECIPE, $(1))))
endef

# Generate all the directory hierarchy of the specified directories
# Arg1 = directories required
define GENERATE-DIR
  $(foreach t, $(call NOSLASH, $(1)), \
    $(if $(filter-out $(__AUTODIR-DONE), $(t)), \
      $(call __AUTODIR-RULE, $(t))))
endef


define __REQUIRE-DIR-RULE
  $(call DEBUG, $(strip $(1)): | $(strip $(call NOSLASH, $(dir $(1)))))
  $(call DEBUG)

  $(1): | $(call NOSLASH, $(dir $(1)))

  $(call GENERATE-DIR, $(dir $(1)))
endef

define REQUIRE-DIR
  $(foreach t, $(1), \
    $(eval $(call __REQUIRE-DIR-RULE, $(t))))
endef
