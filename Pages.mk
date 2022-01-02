
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
# Copyright 2016-2022


# Standard non-recursive make setup
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)
d		:= $(dir)


#########################################
# LOCAL PAGES
#########################################

# Add the pages for the current directory here:
# (pages are just .md files)

# By default all .md files are included:
PAGES_SRC_$(d):=$(wildcard $(d)*.md)

# You can also restrict to specific ones:
#PAGES_SRC_$(d):=$(d)readme.md $(d)index.md

# Include the $(d) for reference to the local directory.
# This is the non-recursive-make trick. 
# See for instance: http://evbergen.home.xs4all.nl/nonrecursive-make.html


#########################################
# SUBDIRECTORIES
#########################################

# Add subdirectories here in random order:


# Load config and pages from blog/
#########################################
# Uncomment the following section for the subdirectories example
#########################################
#dir	:= $(d)blog/
#
#include		$(dir)Pages.mk
#MKCONFIGS+=$(dir)Pages.mk
#########################################

# Load more subdirectories ...
#dir	:= $(d)blog2/

#-include		$(dir)Pages.mk
#MKCONFIGS+=$(dir)Pages.mk

#...

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

