

# Standard non-recursive make things
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)
d		:= $(dir)


#########################################
# Subdirectories, in random order
#########################################

# Load config and pages from blog/
dir	:= $(d)blog/

include		$(dir)Pages.mk
MKCONFIGS+=$(dir)Pages.mk

# Load more subdirectories ...
#dir	:= $(d)blog2/

#include		$(dir)Pages.mk
#MKCONFIGS+=$(dir)Pages.mk

#...

#########################################
# Add local pages to make:
#########################################

PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

# Include the $(d) for reference to the local directory.
# This is the famous non-recursive-make trick!

#########################################
#########################################

### Recursive make stuff, do not change!

# Set make variables to manage the pages

PAGES_$(d):=$(basename $(PAGES_SRC_$(d)))

PAGES+=$(PAGES_$(d))

TGTS_$(d):=$(addsuffix .html,$(PAGES_$(d)))
TGTS+=$(TGTS_$(d))

CONFIGS_$(d):=$(addsuffix .yml,$(PAGES_$(d)))
CONFIGS+=$(CONFIGS_$(d))

DEPS_$(d):=$(addsuffix .d,$(PAGES_$(d)))
DEPS+=$(DEPS_$(d))

CLEAN+=$(TGTS_$(d)) $(CONFIGS_$(d)) $(DEPS_$(d))

-include $(DEPS_$(d))

# Standard non-recursive make things
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))

