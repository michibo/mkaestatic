title: Readme
---
### What is it?

*MKAESTATIC* is a static website generator using markdown and make. The 1-page scripts which are called by the Makefile are written in python.

### Quickstart

#### Preparation

- Copy the *Makefile*, *statico.py*, *configo.py* into your project folder.
- Create two config files: *Pages.mk* and *Site.mk*

#### Setup your pages

In *Pages.mk* you can configure the pages of a directory. The file could look like this:

    TEMPLATE := _templates/template.html

    $(call setup_pages, index readme, $(TEMPLATE))

Two files are added as target for your project: *index.html* and *readme.html*.
You can modify the generated content by editing *index.md* and *readme.md*.
*_templates/template.html* will be used as jinja template for the compilation.

#### Header attributes of pages

In the headers of your markdown source files, attributes which will be passed to the jinja template can be set. For instance, 

index.md:

    ---
    title : My frontpage
    date  : 01.01.1979
    ---

    *content here* 

#### Accessing attributes in jinja templates

You can access these attributes in the jinja template with in the *page* dictionary. For instance, *page.title* or *page.date* will refer to the values given in the header of *index.md* when *index.html* is compiled.

Your jinja template might contain the following line for the *title* attribute in the html header:

    <title>{{ page.sitename|e }} - {{ page.title|e }}</title>

#### Adding global attributes

In *index.md*, we didn't set the *sitename* attribute. If we want to set the same attribute for some variable for all pages, we can set them in the *Site.mk* file.

For example the line 

    $(call set, $(ALL_PAGES), "sitename", "mkeastatic is awesome")

will set the *sitename* attribute appropriately. The attribute can now be accessed in the templates with *page.sitename*.

#### Setting up a ssh-server

#### Start everything

Type

    make serve
