
TEMPLATE := _templates/template.html

$(call setup_pages, $(patsubst %.md,%,$(wildcard $(d)*.md)), $(TEMPLATE))
