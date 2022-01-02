
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
# Copyright 2016-2022


#########################################################################
#########################################################################
#########################################################################
### CONFIGURATION ###

# Optionally setup ssh server with user to push static website to:
SSH_SERVER:= me@myserver.com
SSH_FOLDER:= public_html

# Optionally add further necessary files to the website which will also be deployed:
REQUISITES:=

# For instance
#REQUISITES:= robots.txt .htaccess

#########################################################################
#########################################################################
#########################################################################

# Config file for global website info (e.g. description in header etc)
SITE_CONFIG       := Site.yml

.SUFFIXES:
.SUFFIXES:	.md .html .d .yml

# How to call mkaestatic.py
MD                =          python3 mkaestatic.py $< --configs "$(strip $(CONFIGS))" --site_config $(SITE_CONFIG)
CONF              =          python3 mkaestatic.py $< --parse_yml

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

# Include the root Pages.mk

include Pages.mk

# The Pages.mk are themselves dependencies => rebuild everything if they are changed!

MKCONFIGS+=Pages.mk

$(TGTS) $(DEPS) : $(CONFIGS) $(MKCONFIGS) $(SITE_CONFIG)

# FILES contains all files which are needed by the website (which are known to make):
FILES:= $(sort $(TGTS) $(REQUISITES))

# PHONY targets add more if needed:

.PHONY:		targets
targets:	$(FILES)

# Use standard local http server integrated in python
.PHONY:		serve
serve:      targets
	python3 -m http.server 8000


BUILT_FOLDER:=built

# Copies all necessary files to the BUILT_FOLDER
.PHONY:     build
build:      targets
	rm -rf $(BUILT_FOLDER) && mkdir built && tar cf - $(FILES) | ( cd $(BUILT_FOLDER) && tar xf - )

BUILT_TARFILE:=built.tar.gz

# tar's all the necessary files
.PHONY:     tar
tar:        targets
	tar czf $(BUILT_TARFILE) $(FILES)

# uploads all the necessary files via ssh
.PHONY:		upload
upload:     targets
	tar cf - $(FILES) | ssh $(SSH_SERVER) "cd $(SSH_FOLDER) && tar xf - && chmod 755 . && chmod 755 $(FILES)"

# adds all the necessary files to the local git repository
.PHONY:		git-add-requisites
git-add-requisites:      targets
	git add $(FILES)

.PHONY:		clean
clean:
	rm -f $(CLEAN) && rm -rf $(BUILT_FOLDER) && rm -f $(BUILT_TARFILE)

.SECONDARY:	$(CLEAN)

