
### What is it?

*mkaestatic* is a **static** website generator which uses non-recursive [make](//www.gnu.org/software/make/), [python](//www.python.org/) and [markdown](//daringfireball.net/projects/markdown/). The non-recursive make approach is based Emile van Bergen's article [Implementing non-recursive make](//evbergen.home.xs4all.nl/nonrecursive-make.html) which is itself based on the paper [Recursive Make Considered Harmful](//aegis.sourceforge.net/auug97.pdf).

Additionally, *mkaestatic* strictly uses relative urls inside the generated static page. Therefore, the page can be accessed using the browser directly on the file system, i.e. using file:// instead of http://, without the need for a webserver. 

*mkaestatic* keeps track of requisites using the features of make. It can be easily integrated into other static content generation toolchains based on make as for instance image or pdf rendering scripts. 

### Requirements

To run *mkaestatic* a 
- python (2.7 or 3.x) installation is required. *mkaestatic* additionally uses 
- [mistune](//github.com/lepture/mistune) as its markdown implementation, 
- [jinja2](//jinja.pocoo.org/docs/dev/) as a template engine and 
- [PyYAML](//pyyaml.org/) to read and write config files. 

### Quickstart

#### Preparation

- Copy the *Makefile*, *statico.py*, *configo.py* into your project folder.
- Create two config files: *Pages.mk* and *Site.mk*

#### Setup your pages

In *Pages.mk* you can configure the *pages* of a directory and the subdirectories. The file is quite long, but most of it is just recursive make management. 

The filenames of the page-files can be added in one line of the *Pages.mk* file:

    PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

A page is a markdown file with a .md suffix, which will eventually be compiled to a html-file. The pages must be added to the *Pages.mk*-file in the same directory as the page. A prefix **$(d)** needs to be added file name. This adds the name of the current directory before the path of page in accordance to non-recursive make practice. The make variable *PAGES_SRC_$(d)* must be set to the list of pages:

    ... non recursive make stuff ...
    
    ... subdirectory stuff ...    

    #########################################
    # Add local pages to make:
    #########################################

    PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

    # Include the $(d) for reference to the local directory.
    # This is the famous non-recursive-make trick!

    ... more non recursive make stuff ...

Two files are added as target for your project: *index.html* and *readme.html*, which will be generated from the markdown files *index.md* and *readme.md* respectively. 

#### Setup your subdirectories (optional feature)

To add subdirectories to the mkaestatic tree you need to modify the following section of *Pages.mk*:

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

First subdirectories need to be added in random order. Each subdirectory needs to have its own *Pages.mk* file. You can add a subdirectory by using the three lines

    dir	:= $(d)blog/

    include		$(dir)Pages.mk
    MKCONFIGS+=$(dir)Pages.mk

where *blog/* is replaced by the respective subdirectory. Note, that you need to include the *$(d)* before the directory name. 

In the subdirectory you can add additional pages or subdirectories recursively. The subdirectories will be included in the standard non-recursive make style.

#### Configuration of pages

##### Local attributes (per page)

Every markdown file can have a three dash seperated header. In these headers attributes, which will be passed to the jinja template, can be set. For instance, 

index.md:

    ---
    title : My frontpage
    date  : 01.01.1979
    template : _templates/frontpage.html
    ---

    *content here* 

The **template** attribute has a special role as it sets the *jinja template* which will be used to render the page. A template must be given either in the source file of the page or in the *Site.yml* file where a default template for all pages can be specified (see "Adding global attributes"). 

In the jinja template the attributes can be accessed using the variables **page.title**, **page.date** and **page.template**. See below.

##### Global attributes (per site, i.e. one per mkaestatic instance)

Global attributes can be set in the *Site.yml* file. For example,

Site.yml:

    name : "mkaestatic"
    tagline : "is awesome"

    template : _templates/default.html

will set the *site.name* and *site.tagline* attributes appropriately. The attributes can be accessed in the templates. Additionally, a default template can be specified using the *template* attribute.

#### Accessing page configurations in jinja templates

##### Local and strictly global attributes

You can access the attributes in the jinja template with in the **page**, **site** or **root** variables. For instance, **page.title** or **page.date** will refer to the values given in the header of *index.md* when *index.html* is compiled.

Your jinja template might contain the following line for the **title** attribute in the html header:

    <title>{{ site.name|e }} - {{ page.title|e }}</title>

The |e operator escapes special characters in the variables to html. 

The **site.name** is the same value, the one defined in *Site.yml*, for all pages in the *mkaestatic* instance, whereas **page.title** will differ from page to page depending on the definition of **title** in the header.

##### Accessing attributes via the directory tree

With the **site** and **page** variables, global attributes or the attributes of the *current page*, which is about to be rendered, may be accessed. But in many cases the attributes of other pages are also needed. If for instance a menu shall be rendered on the website, the jinja template needs to know certain attributes, as the title or date, of a bunch of source files. 

*mkaestatic* provides a simple data structure for these situations:

In the jinja template the variable **root** can be accessed. This variable mirrors the structure of the top-level directory in the *mkaestatic* directory tree. The **root** variable is iterable. If we loop over **root**, we iterate over the configurations of the pages in the top-level directory. For instance, 

    {% for p in root if not p.nomenu %}
        <li class="nav-item">
            <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>
        </li>
    {% endfor %}

will render a menu item for every page in the top-level directory, i.e. .md file, which was added in the top-level *Pages.mk*. The page will only be included if the local config of the page does not contain a **nomenu** attribute, because of the 
    
    if not p.nomenu 

filter in the for-loop.

Every page has the additional attribute **url**, which contains the relative url of the page from the top-level directory. As in the line 

    <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>

of the example above, the | localurl filter must be added to obtain a relative url which works for pages also in subdirectories. 

The pages of subdirectories can be traversed by accessing the respective attributes of **root**. For instance,

    {% for p in root.blog %}

    ...

    {% endfor %}

will loop over all pages inside the *blog/* subdirectory. The subdirectory and the pages must have been added to respective *Pages.mk* files.

#### Special attributes

Every page has three special attributes which are set internally by *mkaestatic*: **name**, **url** and **title**. The attribute **name** is the basename of the filename of the md-file for the page. **url** is the url which can be used to reference the page html-file. **title** is the same as **name** by default, but can be overwritten in the local configuration.

Optionally, the attribute **mirror** can be set in the local configuration of a page. **mirror** must be set to the file name of another page, whose content will be merely copied to the html of the page. This can be useful to deal with compatibility in respect to old url schemes.

Let's say for example that *index.html* shall have the same contant as *readme.html*:

index.md:

    ---
    mirror: readme.html
    nomenu: true
    ---

#### Start everything

To test the website use the command 

    make serve

the page can be accessed under the url [localhost:8000](//localhost:8000). *mkaestatic* uses the standard python http server.

#### Setting up a ssh-server

You can use *mkaestatic* to upload your static website to a server via ssh. The necessary ssh-info must be set in the configuration file *Site.mk*: 

Site.mk:

    SSH_SERVER := me@myserver.com
    SSH_FOLDER := public_html

The command 

    make upload

will upload all the generated html files and all requisites of the page, which are known to mkaestatic, to the server. Links in markdown code and links which are filtered with the *localurl* jinja will be automatically included in the upload. 
