**MKAESTATIC**

What is it?
===========
*MKAESTATIC* is a static website generator using markdown and make. The 1-page scripts which are called by the Makefile are written in python.

Quickstart
==========

- Copy the *Makefile*, *statico.py*, *configo.py* into your project folder.
- Create two config files: *Pages.mk* and *Site.mk*

In Pages.mk you can configure the pages of a directory:

    TEMPLATE := _templates/template.html

    $(call setup_pages, index readme, $(TEMPLATE))

Two files are added as target for your project: *index.html* and *readme.html* 
You can modify the generated content by editing *index.md* and *readme.md*
*_templates/template.html* will be used as jinja template for the compilation.

In the headers of your markdown source files, attributes which will be passed to the jinja template can be set.

index.md:
    ---
    title : My frontpage
    date  : 01.01.1979
    ---

    *content here* 

You can access these attributes in your template with config.title or config.date or similar.


