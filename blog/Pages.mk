
TEMPLATE := _templates/template.html

$(call setup_pages, $(patsubst %.md,%,$(wildcard *.md)), $(TEMPLATE))
