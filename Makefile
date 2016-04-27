
.SUFFIXES:
.SUFFIXES:	.md .html .d

MD              :=          python statico.py
DEP              :=          python configo.py

comma :=,

CF_CONFIG       = '{$(CF_LOCAL_$(basename $@)),$(CF_GLOBAL)}'
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
$(eval PAGES_INFOS_$(d):= $(call get_infos, $(PAGES_$(d))) )
endef


define init_single_local
$(eval CF_TEMPLATE_$(strip $(1)) := $(2)) \
$(eval -include $(strip $(1)).d ) \
$(eval $(strip $(1)).html : $(CF_TEMPLATE_$(strip $(1))) )
endef

define set_single_local
$(eval CF_LOCAL_$(strip $(1))+=,$(strip $(2)):$(strip $(3)))
endef

define include_dir
$(eval sp 		:= $(sp).x) \
$(eval dirstack_$(sp)	:= $(d)) \
$(eval d		:= $(d)$(strip $(1))) \
$(eval include $(d)Pages.mk) \
$(eval d		:= $(dirstack_$(sp))) \
$(eval sp		:= $(basename $(sp))) \
$(eval SUBDIRS_$(d)+=$(strip $(1)) )
endef

set = $(foreach p1,$(1),$(call set_single_local,$(p1),$(2),$(3)))

get_info  = {$(CF_LOCAL_$(strip $(1)))}
get_infos = [$(call get_info, $(firstword $(1)))$(foreach p, $(subst $(firstword $(1)),,$(1)),$(comma)$(call get_info, $(p)))]

%.html  :   %.md
	$(MD)  --config $(CF_CONFIG) --template $(CF_TEMPLATE) $< $@

%.d  :   %.md
	$(DEP)  $< $@

all:		targets

include Pages.mk

get_all_pages_info = "dirname":"$(subst /,,$(2))","pages":$(PAGES_INFOS_$(1)$(2)),"subdirs":{$(foreach sd,$(SUBDIRS_$(1)$(2)),$(subst /,,$(sd)):{$(call get_all_pages_info,$(1)$(2),$(sd))})}
CF_GLOBAL := $(call get_all_pages_info)

include Site.mk


.PHONY:		targets
targets:	$(TGTS)

.PHONY:		serve
serve:      targets
	python3 -m http.server 8000

.PHONY:		upload
upload:     targets
	tar cf - $(TGTS) $(STATIC_FOLDERS) | ssh $(SSH_SERVER) "cd $(SSH_FOLDER) && tar xf - && chmod 701 . && chmod 705 -R *"

.PHONY:		clean
clean:
	rm -f $(CLEAN)

.SECONDARY:	$(CLEAN)
