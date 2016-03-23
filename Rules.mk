
sp 		:= $(sp).x
dirstack_$(sp)	:= $(d)
d		:= $(dir)

PAGES := aboutme feyncop

$(call add_pages, $(PAGES))

$(call set, $(PAGES), "sitename", "Michael Borinsky")
$(call set, $(PAGES), "layout", "template.html")
$(call set, feyncop, "title", "feyncop & feyngen")
$(call set, aboutme, "title", "about me")

$(call set, $(PAGES), "pages", $(call get_infos, $(PAGES)))

d		:= $(dirstack_$(sp))
sp		:= $(basename $(sp))

