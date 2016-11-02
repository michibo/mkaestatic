
### What is it? (tl;dr)

*mkaestatic* is a **static** website generator which uses non-recursive [make](//www.gnu.org/software/make/), [python](//www.python.org/), [markdown](//daringfireball.net/projects/markdown/) and jinja. The non-recursive make approach is based Emile van Bergen's article [Implementing non-recursive make](//evbergen.home.xs4all.nl/nonrecursive-make.html) which is itself based on the paper [Recursive Make Considered Harmful](//aegis.sourceforge.net/auug97.pdf). In princible, *mkaestatic* is just a script that ties the powerful tools (i.e. non-recursive make/markdown/jinja) together in the most transparent and lightweight way possible.

Additionally, *mkaestatic* strictly uses relative URLs inside the generated static page. Therefore, the page can be accessed using the browser directly on the file system, i.e. using file:// instead of http://, without the need for a web server. 

*mkaestatic* keeps track of requisites using the features of make. It can be easily integrated into other static content generation tool chains based on make as for instance image or PDF rendering scripts. 

Features:

-   Low-level easily extensible make based static website generator
-   Markdown content / Jinja templates
-   Purely relative URLs!
    -   Websites can be copied in bulk to arbitrary subdirectories of web servers (for instance ~user/ websites) without any modification in code.
    -   Websites can be surfed locally or remotely without a HTTP server. (File server is enough)
-   Arbitrary deep subdirectories powered by non-recursive make.
-   Fast build times even for large projects as changes and dependencies are managed by make.
-   About 300 lines of python/make code. More a script than a program.

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

In *Pages.mk* the *pages* and *subdirectories* of the root directory can be configured. The file is quite long, but most of it is just recursive make management. 

The filenames of the *page*-files can be added to one line of the *Pages.mk* file. The make variable *PAGES_SRC_$(d)* must be set to the list of *pages*:

    PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

A page is a markdown file with a .md suffix, which will eventually be compiled to a HTML-file. A prefix **$(d)** needs to be added filename. This adds the name of the current directory before the path of *page* in accordance to non-recursive make practice. The line needs to be inserted into *Pages.mk* in the following place:

    ... non recursive make stuff ...
    
    ... subdirectory stuff ...    

    #########################################
    # LOCAL PAGES
    #########################################

    PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

    # Include the $(d) for reference to the local directory.
    # This is the famous non-recursive-make trick!

    ... more non recursive make stuff ...

Two files are added as target for your project: *index.html* and *readme.html*, which will be generated from the markdown files *index.md* and *readme.md* respectively. 

#### Setup your subdirectories (optional feature)

To add subdirectories to the mkaestatic tree you need to modify the following section of *Pages.mk*:

    #########################################
    # SUBDIRECTORIES
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

The subdirectories can be added in arbitrary order. Each subdirectory needs to contain its own *Pages.mk* file of the same form as above. You can add a subdirectory by adding the following lines:

    dir	:= $(d)blog/

    include		$(dir)Pages.mk
    MKCONFIGS+=$(dir)Pages.mk

where the folder *blog/* is replaced by the respective subdirectory. Note, that you need to include the **$(d)** again before the directory name. 

In the subdirectory you can add additional *pages* or *subdirectories* recursively by modifying the *Pages.mk* files inside them appropriately.

#### Configuration of pages

##### Local attributes (per page)

Every markdown file can have a three dash separated header, where attributes, which will be passed to the jinja template, can be defined. For instance, 

index.md:

    ---
    title : My frontpage
    date  : 01.01.1979
    template : _templates/frontpage.html
    ---

    *content here* 

The jinja template can now access the attributes using the variables **page.title**, **page.date** and **page.template**.

The **template** attribute has a special role as it sets the *jinja template* which will be used to render the page. A template must be given either in the source file of the page or in the *Site.yml* file where a default template for all pages can be specified (see "Special attributes"). 

##### Global attributes (per site, i.e. one per mkaestatic instance)

Global attributes can be set in the *Site.yml* file. For example,

Site.yml:

    name : "mkaestatic"
    tagline : "is awesome"

    template : _templates/default.html

will set the *site.name* and *site.tagline* attributes. The attributes can be accessed in all templates via the variables **site.name**, **site.tagline**, **site.template**. 

The global **template** attribute in *Site.yml* again has a special role as it can be used to specify a *default template* for all pages.

#### Accessing page configurations in jinja templates

The most important variable which is passed from mkaestatic to the jinja template is the **content** variable. It contains the html-code which was rendered from the markdown input. Normally, you would want to include something like,

    <div>{{ content }}</div>

in the middle of your template for the markdown content to actually be rendered. 

##### Local and strictly global attributes

The set attributes can be accessed in the jinja template with the **page**, **site** or **root** variables. For instance, **page.title** or **page.date** will refer to the values given in the header of *index.md* when *index.html* is compiled.

Your jinja template might contain the following line for the **title** tag side the html header:

    <title>{{ site.name|e }} - {{ page.title|e }}</title>

The jinja filter |e escapes special characters in the variables to html. 

The value of **site.name**, the one defined in *Site.yml*, is similar for all pages in the *mkaestatic* instance, whereas **page.title** will differ from page to page depending on the definition of **title** in the page header.

##### Accessing attributes via the directory tree

With the **site** and **page** variables, global attributes or the attributes of the *current page*, which is about to be rendered, may be accessed. But in many cases the attributes of other pages are also needed. If for instance a menu shall be rendered on the website, the jinja template needs to know certain attributes, as the title or date, of a bunch of source files. 

*mkaestatic* provides a simple data structure for these situations:

In the jinja template the variable **root** can be accessed. This variable mirrors the structure of the top-level directory (the one in which *make* is invoked) in the *mkaestatic* directory tree. The **root** variable is iterable. If we loop over **root**, we iterate over the configurations of the pages in the top-level directory. For instance, 

    {% for p in root if not p.nomenu %}
        <li class="nav-item">
            <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>
        </li>
    {% endfor %}

will render a menu item for every page in the top-level directory (i.e. .md file), which was added in the top-level *Pages.mk*. The page will only be included if the local config of the page does not contain a **nomenu** attribute, because of the 

    if not p.nomenu 

filter in the for-loop.

Every page has the additional attribute **url**, which contains the relative url of the page from the top-level directory. As in the line 

    <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>

of the example above, the | localurl filter must be added to obtain a relative url which works for pages also in subdirectories (see "Special attributes"). 

The pages of *subdirectories* can be traversed by accessing the respective attributes of **root**. For instance,

    {% for p in root.blog %}

    ...

    {% endfor %}

will loop over all pages inside the *blog/* subdirectory. The subdirectory and the pages must have been added to respective *Pages.mk* files.

#### Special attributes

Every page has three special attributes which are set internally by *mkaestatic*: **name**, **url** and **title**. The attribute **name** is the basename of the filename of the md-file for the page. **url** is the URL which can be used to reference the page html-file. **title** is the same as **name** by default, but can be overwritten in the local configuration. 

Optionally, the attribute **mirror** can be set in the local configuration of a page. **mirror** must be set to the filename of another page, whose content will be merely copied to the html of the page. This can be useful to deal with compatibility in respect to old url schemes.

Let's say for example that *index.html* shall have the same content as *readme.html*:

index.md:

    ---
    mirror: readme.html
    nomenu: true
    ---

#### Referencing internal URLs

Local URLs referenced in a markdown file will always be correctly translated and included into the make dependency tree if they start with a slash. The leading slash stands for the top-level (root) directory of the mkaestatic instance.

To reference other pages properly the jinja filter 'localurl', which is implemented by mkaestatic, must be used to translate the URL to the proper relative URL. For instance, 

    <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>

will translate the URL of the page p accordingly. 

The localurl filter must also be used when accessing static local files. For instance, 

    <link rel="stylesheet" href="{{ '/static/css/style.css' | localurl }}">

will translate the local URL '/static/css/style.css' to the respective relative URL which is valid from the currently rendered page. Local URLs used in this way must always start with a slash to indicate the reference to the root directory of the mkaestatic instance. 

Additionally, the filter is used to add the file '/static/css/style.css' to the make dependency tree. This is very convenient as make will give a error message if such an URL cannot be resolved and other tools such as [sass](//sass-lang.com/) can be used to compile the .css file from some source by including a respective rule to the *Makefile*. 

If you want actually want to specify a relative URL leave the leading slash. The URL will be resolved with respect to the directory the current *page* (not the template!).

#### Start everything

To build everything call

    make

in the top-level directory and access the pages using your web browser.

To copy the files to another directory call

    make build

all the necessary files will be copied to the *built* directory inside the root directory. The directory can be copied anywhere without breaking links.

If you really want to you can also start the python toy web server with 

    make serve

the page can be accessed under the URL [localhost:8000](//localhost:8000). 

To pack the website into a tarball call 

    make tar

this will create a file *built.tar.gz* with all the contents of the website. With some archive managers you can even access the website completely inside the tarball without properly unpacking.

#### Uploading to ssh-server

You can use *mkaestatic* to upload your static website to a server via ssh. The necessary ssh-info must be set in the configuration file *Site.mk*: 

Site.mk:

    SSH_SERVER := me@myserver.com
    SSH_FOLDER := public_html

The command 

    make upload

will upload all the generated html files and all requisites of the page, which are in the dependency tree of make, to the server. Links in markdown code and links which are filtered with the *localurl* jinja will be automatically included in the upload. 

If some static file is missing maybe you missed a | localurl filter in some template or a leading slash for a 'absolute' path.

#### Example

If you cloned this directory, ran *make* and everything worked out you can 'surf' the example project. Just open any html file with a browser.

[Blog post](/blog/post1.html)
