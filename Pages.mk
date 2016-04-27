
# Loading subdirectories
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)

# Load config and pages from blog/
d		:= $(d)blog/

SUBCONF := $(d)Pages.mk
include $(SUBCONF)
MKCONFIGS+= $(SUBCONF)

d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))

# Load more subdirectories ...

#sp 		:= $(sp).x
#dirstack_$(sp)	:= $(d)

# Load config and pages from blog2/
#d		:= $(d)blog2/

#SUBCONF := $(d)Pages.mk
#include $(SUBCONF)
#MKCONFIGS+= $(SUBCONF)

#d		:= $(dirstack_$(sp))
#sp		:= $(basename $(sp))


# Add local pages to make:

PAGES_$(d):= $(d)index $(d)readme

# Set make variables to manage the pages

PAGES:=$(PAGES) $(PAGES_$(d))

TGTS_$(d):=$(addsuffix .html,$(PAGES_$(d)))
TGTS:=$(TGTS) $(TGTS_$(d))

CONFIGS_$(d):=$(addsuffix .yml,$(PAGES_$(d)))
CONFIGS:=$(CONFIGS) $(CONFIGS_$(d))

DEPS_$(d):=$(addsuffix .d,$(PAGES_$(d)))

CLEAN+=$(TGTS_$(d)) $(CONFIGS_$(d)) $(DEPS_$(d))
