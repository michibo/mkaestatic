PAGES := index feyncop

$(call add_pages, $(PAGES))

$(call set, index,      "title", "about me")
$(call set, feyncop,    "title", "feyncop & feyngen")

$(call set, $(PAGES),   "pages", $(call get_infos, $(PAGES)))

