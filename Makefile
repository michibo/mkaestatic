
.SUFFIXES:
.SUFFIXES:	.md .html

MD              :=          python statico.py

comma :=,

CF_CONFIG       = '{$(CF_LOCAL_$(basename $@))}'
CF_TEMPLATE     = $(CF_TEMPLATE_$(basename $@))

TGTS:=

define add_pages
$(eval PAGES_$(d):=$(1)) \
$(eval ALL_PAGES+=$(PAGES_$(d))) \
$(eval TGTS_$(d):=$(addsuffix .html,$(1))) \
$(eval TGTS+=$(TGTS_$(d))) \
$(eval CLEAN+=$(TGTS_$(d))) \
$(eval $(TGTS_$(d)) : Site.mk $(d)Pages.mk $(d)$(2) ) \
$(foreach p1,$(1),$(call init_single_local,$(p1),$(d)$(2)))
endef

DIR_PAGES = $(PAGES_$(d))

define init_single_local
$(eval CF_LOCAL_$(d)$(strip $(1)) := "url":"$(d)$(strip $(1)).html") \
$(eval CF_TEMPLATE_$(d)$(strip $(1)) := $(2))
endef

define set_single_local
$(eval CF_LOCAL_$(d)$(strip $(1))+=,$(strip $(2)):$(strip $(3)))
endef

define include_dir
$(eval sp 		:= $(sp).x) \
$(eval dirstack_$(sp)	:= $(d)) \
$(eval d		:= $(1)) \
$(eval include $(1)/Pages.mk) \
$(eval d		:= $(dirstack_$(sp))) \
$(eval sp		:= $(basename $(sp)))
endef

set = $(foreach p1,$(1),$(call set_single_local,$(p1),$(2),$(3)))

get_info  = {$(CF_LOCAL_$(d)$(strip $(1)))}
make_info_blob = $(call get_info, $(1))
get_infos = [$(call make_info_blob, $(firstword $(1)))$(foreach p, $(subst $(firstword $(1)),,$(1)),$(comma)$(call make_info_blob, $(p)))]

%.html  :   %.md
	$(MD)  --config $(CF_CONFIG) --template $(CF_TEMPLATE) $< $@

%.md::
	touch $@


all:		targets

include Pages.mk

include Site.mk


.PHONY:		targets
targets:	$(TGTS)

.PHONY:		serve
serve:      targets
	python -m http.server 8000

.PHONY:		upload
upload:     targets
	tar cf - $(TGTS) $(STATIC_FOLDERS) | ssh $(SSH_SERVER) "cd $(SSH_FOLDER) && tar xf - && chmod 701 . && chmod 705 -R *"

.PHONY:		clean
clean:
	rm -f $(CLEAN)

.SECONDARY:	$(CLEAN)
