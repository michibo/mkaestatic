
$(warning $(d))
# Loading subdirectories
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)

# Load config and pages from blog/
d		:= $(d)archive/

SUBCONF := $(d)Pages.mk
include $(SUBCONF)
MKCONFIGS+= $(SUBCONF)

d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))

$(warning $(d))

# Add local pages to make:
# All .md files in the directory in this case.

PAGES_$(d):= $(patsubst %.md,%,$(wildcard $(d)*.md))


# Set make variables to manage the pages

PAGES:=$(PAGES) $(PAGES_$(d))

TGTS_$(d):=$(addsuffix .html,$(PAGES_$(d)))
TGTS:=$(TGTS) $(TGTS_$(d))

CONFIGS_$(d):=$(addsuffix .yml,$(PAGES_$(d)))
CONFIGS:=$(CONFIGS) $(CONFIGS_$(d))

DEPS_$(d):=$(addsuffix .d,$(PAGES_$(d)))

CLEAN:=$(CLEAN) $(TGTS_$(d)) $(CONFIGS_$(d)) $(DEPS_$(d)) 
