
TEMPLATE := _templates/template.html

$(call add_pages, index project1 project2 artsy, $(TEMPLATE))

$(call set, index,    "title", "My Blag")
$(call set, project1,    "title", "Project 1")
$(call set, project2,    "title", "Project 2")
$(call set, artsy,    "title", "Artsy stuff")

DIR_PAGES_INFO = $(call get_infos, $(DIR_PAGES))
$(call set, $(DIR_PAGES), "pages", $(DIR_PAGES_INFO))

