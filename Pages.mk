
$(call include_dir, blog/)

TEMPLATE := _templates/template.html

$(call setup_pages, index readme flo, $(TEMPLATE))

