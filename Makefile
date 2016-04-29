
.SUFFIXES:
.SUFFIXES:	.md .html .d .yml

MD                =          python statico.py $< --configs "$(strip $(CONFIGS))" --site_config $(SITE_CONFIG) --default_layout $(DEFAULT_TEMPLATE)
CONF              =          python configo.py $<

SITE_CONFIG       := Site.yml

PAGES:=
TGTS:=
CONFIGS:=
CLEAN:=
MKCONFIGS:=
DEPS:=

%.html  :   %.md
	$(MD)

%.yml   :   %.md
	$(CONF)

%.d     :   %.md
	$(MD)

all:		targets

include Pages.mk
include Site.mk

MKCONFIGS+=Pages.mk Site.mk

$(TGTS) $(DEPS) : $(CONFIGS) $(MKCONFIGS) $(SITE_CONFIG)

FILES:= $(sort $(TGTS) $(REQUISITES))

.PHONY:		targets
targets:	$(FILES)

.PHONY:		serve
serve:      targets
	python3 -m http.server 8000

.PHONY:		upload
upload:     targets
	tar cf - $(FILES) | ssh $(SSH_SERVER) "cd $(SSH_FOLDER) && tar xf - && chmod 701 . && chmod 705 $(FILES)"

.PHONY:		clean
clean:
	rm -f $(CLEAN)

.SECONDARY:	$(CLEAN)
