
# This is the Makefile for the mkaestatic 
# program/script collection. Together with 
# the python scripts statico.py and configo.py 
# this can be used to generate static websites. 
# 
# You can modify the file according to your needs. 
# For instance, code for automatic css generation, 
# for automatic image resizing, etc. could be included.
#
# Author: Michael Borinsky
# Github: https://github.com/michibo/mkaestatic
# License: MIT
# Copyright 2016

.SUFFIXES:
.SUFFIXES:	.md .html .d .yml

# How to call statico.py and configo.py:

MD                =          python statico.py $< --configs "$(strip $(CONFIGS))" --site_config $(SITE_CONFIG)
CONF              =          python configo.py $<

SITE_CONFIG       := Site.yml

# Start with empty page/dependency lists:
PAGES:=
TGTS:=
CONFIGS:=
CLEAN:=
MKCONFIGS:=
DEPS:=

# Statico generates html AND dependency files (.d):
%.html  :   %.md
	$(MD)

%.d     :   %.md
	$(MD)

# Configo generates .yml files. This is a workaround to prohibit a complete rebuild after changes of md-file content:
 
%.yml   :   %.md
	$(CONF)

all:		targets

# Include the root Pages.mk and the global Site.mk

include Pages.mk
include Site.mk

# The Pages.mk and Site.mk are themselves dependencies => rebuild everything if they are changed!

MKCONFIGS+=Pages.mk Site.mk

$(TGTS) $(DEPS) : $(CONFIGS) $(MKCONFIGS) $(SITE_CONFIG)

# FILES contains all files which are needed by the website (which are known to make):

FILES:= $(sort $(TGTS) $(REQUISITES))

# PHONY targets add more if needed:

.PHONY:		targets
targets:	$(FILES)

.PHONY:		serve
serve:      targets
	python3 -m http.server 8000


BUILT_FOLDER:=built

.PHONY:     build
build:      targets
	rm -r $(BUILT_FOLDER) && mkdir built && tar cf - $(FILES) | ( cd $(BUILT_FOLDER) && tar xf - )

BUILT_TARFILE:=built.tar.gz

.PHONY:     tar
tar:        targets
	tar czf $(BUILT_TARFILE) $(FILES)

.PHONY:		upload
upload:     targets
	tar cf - $(FILES) | ssh $(SSH_SERVER) "cd $(SSH_FOLDER) && tar xf - && chmod 701 . && chmod 705 $(FILES)"

.PHONY:		clean
clean:
	rm -f $(CLEAN) && rm -rf $(BUILT_FOLDER) && rm -f $(BUILT_TARFILE)

.SECONDARY:	$(CLEAN)
