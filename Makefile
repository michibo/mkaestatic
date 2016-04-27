
.SUFFIXES:
.SUFFIXES:	.md .html .d .yml

MD                :=          python statico.py
CONF              :=          python configo.py
DEP               :=          python depico.py

comma :=,

CF_CONFIG       = '{$(CF_LOCAL_$(basename $@)),$(CF_GLOBAL)}'
CF_TEMPLATE     = $(CF_TEMPLATE_$(basename $@))

TGTS:=

define setup_pages
$(eval PAGES_$(d):=$(1)) \
$(eval ALL_PAGES+=$(PAGES_$(d))) \
$(eval TGTS_$(d):=$(addsuffix .html,$(1))) \
$(eval CONFS_$(d):=$(addsuffix .yml,$(1))) \
$(eval DEPS_$(d):=$(addsuffix .d,$(1))) \
$(eval TGTS+=$(TGTS_$(d))) \
$(eval CLEAN+=$(TGTS_$(d)) $(CONFS_$(d)) $(DEPS_$(d))) \
$(eval $(TGTS_$(d)) $(DEPS_$(d)) : Site.mk $(d)Pages.mk ) \
$(foreach p,$(1),$(call init_single_local,$(p),$(2)))
endef


define init_single_local
$(eval -include $(strip $(1)).d )
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

%.html  :   %.md
	$(MD) $< $@ --configs $(CONFIGS)

%.yml   :   %.md
	$(CONF)  $< $@

%.d     :   %.md

all:		targets

include Pages.mk
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
