system := diablo


module-path := $(dir $(lastword $(MAKEFILE_LIST)))

include src/generic/build.mk
include src/generic/system.mk
