
## 1 What is it?

**mkaestatic** is a simple static website generator. It combines the standard tools [make](//www.gnu.org/software/make/), [python](//www.python.org/), [Markdown](//daringfireball.net/projects/markdown/) and [Jinja](https://palletsprojects.com/p/jinja/).

As a static website generator **mkaestatic** converts Markdown files (for instance *readme.md*, *about.md* and *contact.md*) into HTML files (for instance *readme.html*, *about.html* and *contact.html*). The Markdown to HTML conversation is controlled by a Jinja HTML template file, a configuration file and options that are integrated in the Markdown files. 

**mkaestatic** has a simple command line interface that allows rapid local website development and testing. This interface is entirely based on **make** and integrates smoothly with static website hosting services based on ssh or website hosting via [GitHub Pages](https://pages.github.com/).

### Features

-   Easily extensible [make](//www.gnu.org/software/make/) and [python](//www.python.org/) based static website generator
-   Markdown content and Jinja2 HTML templates
-   Purely relative URLs that means
    -   Websites can be copied in bulk to arbitrary subdirectories of web servers (for instance ~user/ websites) without any modification in code.
    -   Websites can be accessed locally or remotely without a HTTP server (i.e. using file:// instead of http://)
    -   Websites can just be a git repository hosted for instance via [GitHub Pages](https://pages.github.com/)
-   Arbitrary deep subdirectories
-   Fast build times even for large projects as changes and dependencies are managed by make
-   Keeps track of static requisites (as for instance static .css and .js files) using make
-   Can be easily integrated with other content generating tools (such as [sass](//sass-lang.com/)) via make
-   Only about 350 documented lines of python code

### Requirements

To run **mkaestatic** a python3 installation is required. **mkaestatic** additionally requires
- [Mistune](//github.com/lepture/mistune) as its Markdown implementation (Mistune >= 2.0), 
- [Jinja2](//jinja.pocoo.org/docs/dev/) as a template engine and 
- [PyYAML](//pyyaml.org/) to read and write configuration files. 

The extra python packages can be installed for instance with *pip*

    pip install mistune jinja2 pyyaml
## 2 Quickstart

### Preparation

Either clone, fork or template the [repository](https://github.com/michibo/mkaestatic) on GitHub or copy the 

- code files *mkaestatic.py*, *Makefile* and *Pages.mk*
- and the global configuration file *Site.yml*
- at least one example Markdown file *readme.md*, *example.md*, *contact.md* and/or *index.md*

### Create a HTML template

To use **mkaestatic** a Jinja HTML template is needed. As a start you can try the one which is contained in this repository *_template/default.html* and adapt it to your needs. The path to the template file must either be given in the global *Site.yml* configuration file or in each .md file individually. 

### Create Markdown files

The next step is to create actual website content using Markdown (.md) files. This repository contains the example Markdown files,

- readme.md (this file)
- example.md (an example with a referenced image)
- index.md (mirrors the readme.md file)
- contact.md (another example)
- other pages (i.e. .md files) in the blog directory to illustrate how subdirectories work
which should illustrate most of the functionality of **mkaestatic**.

### Test your website locally and deploy it

To test the resulting website you can call

    make serve
This command converts all .md files into HTML files using **mkaestatic** and starts a local webserver with which the result can be tested. The command line output indicates how you can access the website in your browser. To immediately see something in the browser when the local webserver is accessed, you need to create an *index.md* file that will be compiled to an *index.html* file.

The other **mkaestatic** commands are 

    make
which converts (compiles) the .md files to HTML files,

    make clean
which deletes all temporary files (including .html files that were generated),

    make build
which copies all the deployment files into a *built* folder. This folder contains all the necessary files to serve the website and no other files,

    make tar
which creates a tar archive *built.tar.gz* with the complete website and no other files,

    make upload
which uploads the complete website to a folder via ssh (the ssh server information must be set in the *Makefile* for this to work).

    make git-add-requisites
which adds all the files that are needed to serve the website to the local git repository. This command is especially useful in combination with [GitHub Pages](https://pages.github.com/) or a similar service.

## 3 Basic features

### Local URLs and requisites

#### Local URLs in Markdown files

The Markdown (.md) files can include hyperlinks to other pages (i.e. other .md/.html files) using the usual Markdown syntax. For instance,

    Hello this is a line of Markdown code that refers to the [readme](/readme.html) page.
will produce the text with a link to the *readme.html* file. The *readme.html* file can either be an externally provided file or a file which is also generated by **mkaestatic** from *readme.md*. The hyperlink is translated to a *local relatively referenced* link in the HTML-code. 

You can also included links to static objects this way, 

    Here you can download a [fancy pdf file](/static/fancy.pdf).
which generates a link to the static PDF-file *static/fancy.pdf*. **mkaestatic** will produce an error if the file *static/fancy.pdf* does not exist. If it exists it will be included as a **requisite**. That means it is included in the set of all files that need to be deployed. It is copied together with the all the generated html files into the built folder or uploaded into an ssh server.  Local URLs referenced in a Markdown file will always be correctly translated and included into the **make** dependency tree if they start with a slash as in the preceding to examples. The leading slash stands for the top-level directory of your **mkaestatic** workspace directory (i.e. the directory which contains the *Makefile*).

#### Local URLs in Jinja templates

To reference local pages (local .md/.html file pairs) in template files the Jinja filter **localurl**, which is provided by **mkaestatic**, must be used to translate the URL to the proper relative URL. For instance, 

    <a href="{{ p.url | localurl }}">A link to the page p</a>
will translate the URL of the page p (i.e. a local .md/.html file pair) accordingly. 

The **localurl** filter must also be used when accessing static local files. For instance, 

    <link rel="stylesheet" href="{{ '/static/css/style.css' | localurl }}">
will translate the local URL '/static/css/style.css' to the respective relative URL which is valid from the currently rendered page and it will add the file */static/css/style.css* as a requisite and to the make dependency tree. 
This way other tools such as [sass](//sass-lang.com/) can be used to compile the .css file from some source by including a respective rule to the *Makefile*. As in the Markdown files, local URLs used in this way must start with a slash to indicate the reference to the root directory of the **mkaestatic** instance. 

#### Using actual relative URLs (discouraged)

If you actually want to specify a relative URL (for instance from a subdirectory) do not use the leading slash. The URL will be resolved with respect to the directory the current *page* (not the template!).

#### Additional static requisites

Additional requisites that might not be referenced by any website can be included in the header of the *Makefile* in the configuration variable **REQUISITES**. For instance,

    REQUISITES:= robots.txt .htaccess
also includes the files *robots.txt* and *.htaccess* which are neither referenced in any Markdown file nor in a template via **localurl**.

### Configuration of pages

#### Local attributes (per page)

Every Markdown file can have a three dash separated header (as in [Jekyll](https://jekyllrb.com/)), where attributes can be defined. These attributes can be accessed from the Jinja HTML template. For instance, 

    ---
    title : My frontpage
    date  : 01.01.1979
    template : _templates/frontpage.html
    ---

    *content here* 
The Jinja template can now access the attributes using the variables **page.title**, **page.date** and **page.template**.

The **template** attribute has a special role as it sets the *Jinja HTML template* which will be used to render the HTML file from the Markdown file. A template must be given either in the source file of the page or in the global *Site.yml* configuration file where a default template for all pages can be specified. 

#### Global attributes (per site, i.e. one per mkaestatic instance)

Global attributes can be set in the global *Site.yml* configuration file. For example,

    name : "mkaestatic"
    tagline : "is awesome"

    template : _templates/default.html
will for instance set the global **name**, **tagline** and **template** attributes. These attributes can be accessed in all templates via the variables **site.name**, **site.tagline**, **site.template**. 

The global **template** attribute in *Site.yml* again has a special role as it can be used to specify a *default template* for all Markdown files.

#### Accessing page configurations in Jinja templates

The most important variable which is passed from mkaestatic to the Jinja template is the **content** variable. It contains the HTML-code which was rendered from the Markdown input. For instance you can add 

    <div>{{ content }}</div>
in the middle of your template for the Markdown content to actually be rendered. 

#### Local and strictly global attributes

All attributes can be accessed in the Jinja template with the **page**, **site** or **root** variables. For instance, **page.title** or **page.date** will refer to the values given in the Markdown header that was given as an example above.

Your Jinja template might contain the following line for the **title** tag side the HTML header:

    <title>{{ site.name|e }} - {{ page.title|e }}</title>
The value of **site.name**, the one defined in *Site.yml*, is similar for all pages in the *mkaestatic* instance, whereas **page.title** will differ from page to page depending on the definition of **title** in the page header.

The Jinja filter |e escapes special characters in the variables to HTML. 

#### Special attributes

Every page has three special attributes which are set internally by *mkaestatic*: **name**, **url** and **title**. The attribute **name** is the basename of the filename of the Markdown (.md) file. **url** is the URL which can be used to reference the resulting HTML-file. **title** is the same as **name** by default, but can be overwritten in the local configuration. 

Optionally, the attribute **mirror** can be set in the local configuration of a page. **mirror** must be set to the filename of another page, whose content will be merely copied to the HTML of the page. This can be useful to deal with compatibility in respect to old url schemes.

Let's say for example that *index.html* shall have the same content as *readme.html*:

index.md:

    ---
    mirror: readme.HTML
    nomenu: true
    ---
#### Accessing attributes via the directory tree

With the **site** and **page** variables, global attributes or the attributes of the *current Markdown page*, which is about to be rendered to HTML, may be accessed. But in many cases the attributes of other pages are also needed. If for instance a menu shall be rendered on the website, the Jinja template needs to know certain attributes, as the title or date, of a bunch of source files. 

*mkaestatic* provides a simple data structure for these situations:

In the Jinja template the variable **root** can be accessed. This variable mirrors the structure of the top-level directory (the one in which **make** is invoked and which contains the *Makefile*) in the **mkaestatic** directory tree. The **root** variable is iterable. If we loop over **root**, we iterate over the configurations of the pages in the top-level directory. For instance, 

    {% for p in root if not p.nomenu %}
        <li class="nav-item">
            <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>
        </li>
    {% endfor %}
will render a menu item for every page in the top-level directory (i.e. .md file), which was added in the top-level *Pages.mk*. The page will only be included if the local configuration of the page does not contain a **nomenu** attribute, because of the 

    if not p.nomenu 
filter in the for-loop.

Every page has the additional attribute **url**, which contains the relative url of the page from the top-level directory. As in the line 

    <a href="{{ p.url | localurl }}">{{ p.title|e }}</a>
of the example above, the | localurl filter must be added to obtain a relative url which works for pages also in subdirectories (see "Special attributes"). 

The pages of *subdirectories* can be iterated over by accessing the respective attributes of **root**. For instance,

    {% for p in root.blog %}

    ...

    {% endfor %}
will loop over all pages inside the *blog/* subdirectory. Such a complete subdirectory example is contained in the *Pages.mk* of this repository. For a working illustration you have to uncomment the respective section in the SUBDIRECTORIES part of *Pages.mk* (see also the next section).

## 4 Advanced features and further details

### Under The Hood

**mkaestatics** non-recursive make approach is based Emile van Bergen's article [Implementing non-recursive make](//evbergen.home.xs4all.nl/nonrecursive-make.html) which is itself based on the paper [Recursive Make Considered Harmful](//aegis.sourceforge.net/auug97.pdf). 

### Pages.mk files in detail

In *Pages.mk* the *pages* and *subdirectories* of the root directory can be configured. The file is quite long, but most of it is just recursive make management. 

By default all .md files in the directory are included as pages in the ordinary *Pages.mk* file. The filenames of the *page*-files can also be added one-by-one to the *Pages.mk* file. 
To do so comment out or delete the line 

    PAGES_SRC_$(d):=$(wildcard $(d)*.md)
in the *Pages.mk* file. The make variable *PAGES_SRC_$(d)* must be set to the list of *pages*. For instance you can add use the line

    PAGES_SRC_$(d):=$(d)index.md $(d)readme.md
instead. 
A page is a Markdown file with a .md suffix, which will eventually be compiled to a HTML-file. A prefix **$(d)** needs to be added filename. This adds the name of the current directory before the path of *page* in accordance to non-recursive make practice. The line needs to be inserted into *Pages.mk* in the following place:

    ... non recursive make stuff ...

    #########################################
    # LOCAL PAGES
    #########################################

    ...

    PAGES_SRC_$(d):=$(d)index.md $(d)readme.md

    # Include the $(d) for reference to the local directory.
    # This is the famous non-recursive-make trick!

    ... more non recursive make stuff ...
Two files are added as target for your project: *index.html* and *readme.html*, which will be generated from the Markdown files *index.md* and *readme.md* respectively. 

### Websites with subdirectories

To add subdirectories to the **mkaestatic** tree you need to modify (or uncomment) the following section of *Pages.mk*:

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
Uncommenting these lines in the present repository produces an example with a working subdirectory. 

The subdirectories can be added in arbitrary order. Each subdirectory needs to contain its own *Pages.mk* file of the same form as above. You can add a subdirectory by adding the following lines:

    dir	:= $(d)blog/

    include		$(dir)Pages.mk
    MKCONFIGS+=$(dir)Pages.mk
where the folder *blog/* is replaced by the respective subdirectory. Note, that you need to include the **$(d)** again before the directory name. In the subdirectory you can add additional *pages* or *subdirectories* recursively by modifying the *Pages.mk* files inside them appropriately.


### ssh-server upload

You can use *mkaestatic* to upload your static website to a server via ssh. The necessary ssh-info must be set in the *Makefile*: 

    SSH_SERVER := me@myserver.com
    SSH_FOLDER := public_html
The command 

    make upload
will upload all the generated HTML files and all requisites of the page, which are in the dependency tree of make, to the server and put them into the *~/$SSH_FOLDER/* of the current user. Links in Markdown code and links which are filtered with the *localurl* Jinja will be automatically included in the upload. 


If some static file is missing maybe you missed a | localurl filter in some template or a leading slash for a 'absolute' path.

