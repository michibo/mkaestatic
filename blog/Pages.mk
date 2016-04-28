
# Standard non-recursive make things
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)
d		:= $(dir)


# Subdirectories, in random order

# Loading subdirectories
dir	:= $(d)archive/

include		$(dir)Pages.mk
MKCONFIGS+=$(dir)Pages.mk


# Add local pages to make:

PAGES_$(d):= $(patsubst %.md,%,$(wildcard $(d)*.md))
# This includes all .md files in the 
# directory in this case.


# Set make variables to manage the pages

PAGES+=$(PAGES_$(d))

TGTS_$(d):=$(addsuffix .html,$(PAGES_$(d)))
TGTS+=$(TGTS_$(d))

CONFIGS_$(d):=$(addsuffix .yml,$(PAGES_$(d)))
CONFIGS+=$(CONFIGS_$(d))

DEPS_$(d):=$(addsuffix .d,$(PAGES_$(d)))
DEPS+=$(DEPS_$(d))

CLEAN+=$(TGTS_$(d)) $(CONFIGS_$(d)) $(DEPS_$(d))


# Standard non-recursive make things
d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))

