
### What is it?

*MKAESTATIC* is a static website generator using non-recursive make, python and markdown. The non-recursive make approach is based Emile van Bergen's article [Implementing non-recursive make](https://evbergen.home.xs4all.nl/nonrecursive-make.html) which is itself based on the paper [Recursive Make Considered Harmful](http://aegis.sourceforge.net/auug97.pdf).

### Quickstart

#### Preparation

- Copy the *Makefile*, *statico.py*, *configo.py* into your project folder.
- Create two config files: *Pages.mk* and *Site.mk*

#### Setup your subdirectories

In *Pages.mk* you can configure the pages of a directory and the subdirectories. The file is quite long, but most of it is just recursive make management. 
First subdirectories need to be added in random order. Each subdirectory needs to have its own *Pages.mk* file. You can add a subdirectory by using the three lines

    dir	:= $(d)blog/

    include		$(dir)Pages.mk
    MKCONFIGS+=$(dir)Pages.mk

where **blog/** is replaced by the respective subdirectory. Note, that you need to include the **$(d)** before the directory name. This variable adds the name of the current directory to the 
name of the subdirectory.

#### Setup your pages

The names of the page files can be added in one line of the *Pages.mk* file. Every page file is assumed to be some Markdown file in the current directory (same directory as the Pages.mk - file that you are editing). As for the subdirectory the prefix **$(d)** needs to be added file name. 

    ... non recursive make stuff ...

    #########################################
    # Subdirectories, in random order
    #########################################

    # Load config and pages from blog/
    dir	:= $(d)blog/

    include		$(dir)Pages.mk
    MKCONFIGS+=$(dir)Pages.mk

    # Load more subdirectories ...
    #dir	:= $(d)blog2/

    #include		$(dir)Pages.mk
    #MKCONFIGS+=$(dir)Pages.mk

    #...

    #########################################
    # Add local pages to make:
    #########################################

    PAGES_$(d):=$(d)index $(d)readme

    # Include the $(d) for reference to the local directory.
    # This is the famous non-recursive-make trick!

    ... more non recursive make stuff ...

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
