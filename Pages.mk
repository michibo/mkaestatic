
TEMPLATE := _templates/template.html

$(call add_pages, index feyncop, $(TEMPLATE))

$(call set, index,    "title", "about me")
$(call set, feyncop,  "title", "feyncop & feyngen")

DIR_PAGES_INFO = $(call get_infos, $(DIR_PAGES))
$(call set, $(DIR_PAGES), "pages", $(DIR_PAGES_INFO))

