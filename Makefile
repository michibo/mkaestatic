
.SUFFIXES:
.SUFFIXES:	.md .html .d

MD              :=          python statico.py
DEP              :=          python configo.py

comma :=,

CF_CONFIG       = '{$(CF_LOCAL_$(basename $@))}'
CF_TEMPLATE     = $(CF_TEMPLATE_$(basename $@))

TGTS:=

define setup_pages
$(eval PAGES_$(d):=$(1)) \
$(eval ALL_PAGES+=$(PAGES_$(d))) \
$(eval TGTS_$(d):=$(addsuffix .html,$(1))) \
$(eval DEPS_$(d):=$(addsuffix .d,$(1))) \
$(eval TGTS_$(d) : DEPS_$(d) ) \
$(eval TGTS+=$(TGTS_$(d))) \
$(eval CLEAN+=$(TGTS_$(d)) $(DEPS_$(d))) \
$(eval $(TGTS_$(d)) $(DEPS_$(d)) : Site.mk $(d)Pages.mk ) \
$(foreach p1,$(1),$(call init_single_local,$(p1),$(2))) \
$(eval PAGES_INFOS_$(d):= $(call get_infos, $(PAGES_$(d))) ) \
$(call set, $(PAGES_$(d)), "pages", $(PAGES_INFOS_$(d))) \
$(call set, $(PAGES_$(d)), "subdirs", )
endef

define init_single_local
$(eval CF_TEMPLATE_$(d)$(strip $(1)) := $(2)) \
$(eval -include $(d)$(strip $(1)).d ) \
$(eval $(d)$(strip $(1)).html : $(CF_TEMPLATE_$(d)$(strip $(1))) )
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
$(eval sp		:= $(basename $(sp))) \
$(eval SUBDIRS_$(d)+= $(1) )
endef

set = $(foreach p1,$(1),$(call set_single_local,$(p1),$(2),$(3)))

get_info  = {$(CF_LOCAL_$(d)$(strip $(1)))}
get_infos = [$(call get_info, $(firstword $(1)))$(foreach p, $(subst $(firstword $(1)),,$(1)),$(comma)$(call get_info, $(p)))]

get_subdir_info = "$(strip $(1))":{"url":$(d)$(strip $(1))/index.html}

%.html  :   %.md
	$(MD)  --config $(CF_CONFIG) --template $(CF_TEMPLATE) $< $@

%.d  :   %.md
	$(DEP)  $< $@


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
