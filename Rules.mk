
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)
d		:= $(dir)

CF_$(d)     := '{"layout" : "index.html", \
                 "title" : "Michael Borinsky"}'

TGTS_$(d)   := $(d)/aboutme.html $(d)/feyncop.html
DEPS_$(d)	:= $(TGTS_$(d):%=%.d)

CLEAN		:= $(CLEAN) $(TGTS_$(d)) $(DEPS_$(d))

TGTS_$(d):	$(d)/Rules.mk

TGTS_$(d):  CF_TGT:= $(CF_$(d))

include	$(DEPS_$(d))

d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))

