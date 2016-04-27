
.SUFFIXES:
.SUFFIXES:	.md .html .d .yml

MD                :=          python statico.py
CONF              :=          python configo.py
DEP               :=          python depico.py

CF_TEMPLATE     = $(CF_TEMPLATE_$(basename $@))

SITE_CONFIG     := Site.yml

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
	$(MD) $< $@ --configs "$(strip $(CONFIGS))" --site_config $(SITE_CONFIG) --default_layout $(DEFAULT_TEMPLATE)

%.yml   :   %.md
	$(CONF) $< $@

%.d     :   %.md

all:		targets

include Pages.mk
include Site.mk

MKCONFIGS+= Pages.mk Site.mk

$(TGTS) : $(CONFIGS) $(MKCONFIGS)

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
