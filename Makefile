
.SUFFIXES:
.SUFFIXES:	.md .html .d

MD              :=          python statico.py
DEP             :=          python statico.py -d

comma :=,

CF_TGT          = $(CF_LOCAL_$(basename $@))

TGTS:=

define add_pages
$(eval TGTS_$(d):=$(addsuffix .html,$(1))) \
$(eval DEPS_$(d):=$(addsuffix .d,$(1))) \
$(eval PAGES_$(d):=$(1)) \
$(eval ALL_PAGES+=$(PAGES_$(d)))\
$(eval TGTS+=$(TGTS_$(d))) \
$(eval CLEAN+=$(TGTS_$(d)) $(DEPS_$(d))) \
$(eval $(TGTS_$(d)):	$(d)Pages.mk ) \
$(eval -include	$(DEPS_$(d))) \
$(foreach p1,$(1),$(call init_single_local,$(p1),"url","$(d)$(p1).html"))
endef

define init_single_local
$(eval CF_LOCAL_$(d)$(strip $(1)):=$(strip $(2)):$(strip $(3)))
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
	$(MD)  --config '{$(CF_TGT)}' $< $@

%.d     :   %.md
	$(DEP) --config '{$(CF_TGT)}' $< $@

all:		targets

include Pages.mk
PAGES:=

include Site.mk


.PHONY:		targets
targets:	$(TGTS)

.PHONY:		serve
serve:      targets
	python -m http.server 8000

.PHONY:		upload
upload:     targets
	tar cf - $(TGTS) $(STATIC_FOLDER) | ssh $(SSH_SERVER) "cd $(SSH_FOLDER) && tar xf - && chmod 701 . && chmod 705 -R *"

.PHONY:		clean
clean:
	rm -f $(CLEAN)

.SECONDARY:	$(CLEAN)
