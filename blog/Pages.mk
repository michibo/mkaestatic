
$(call include_dir, archive/)

TEMPLATE := _templates/template.html

$(call setup_pages, $(patsubst %.md,%,$(wildcard $(d)*.md)), $(TEMPLATE))
