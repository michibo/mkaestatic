
# This is a Pages.mk file as part of the 
# mkaestatic static website generator. 
#
# This make configuration file must be copied 
# to every subdirectory of the project. 
# 
# The marked sections SUBDIRECTORIES and 
# LOCAL PAGES need to be modified accordingly. 
#
# Author: Michael Borinsky
# Github: https://github.com/michibo/mkaestatic
# License: MIT
# Copyright 2016


# Standard non-recursive make things
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)
d		:= $(dir)


#########################################
# SUBDIRECTORIES
#########################################

# Add subdirectories here in random order:

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
# LOCAL PAGES
#########################################

# Add the pages for the current directory here:
# (pages are just .md files)

PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

# Include the $(d) for reference to the local directory.
# This is the famous non-recursive-make trick. 
# See for instance: http://evbergen.home.xs4all.nl/nonrecursive-make.html

#########################################
#########################################

### Recursive make stuff, no need to change.

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

