import argparse

from codecs import open

import os
from os import path
from urlparse import urlparse

import yaml, jinja2, mistune

from mdsplit import mdsplit
from dirlisttree import dirlisttree

def load_configs( config_fns, input_cfg_fn, input_root ):
    cfg_tree = dirlisttree()

    for cfg_fn in config_fns:
        if path.isabs(cfg_fn):
            raise ValueError('Error: You cannot use absolute paths here: %s' % cfg_fn)

        cfg_fn_base, _ = path.splitext( cfg_fn )
        _, cfg_name = path.split(cfg_fn_base)
        html_fn = "/" + cfg_fn_base + ".html"

        with open(cfg_fn, 'r', encoding='utf-8') as cfg_file:
            cfg = yaml.load(cfg_file.read())

        cfg['url'] = html_fn
        cfg['name'] = cfg_name

        if 'title' not in cfg:
            cfg['title'] = cfg_name

        if cfg_fn == input_cfg_fn:
            config = cfg

        pure_fn, _ = path.split( cfg_fn )

        cfg_tree[pure_fn].append(cfg)

    return cfg_tree, config

def render(md_source, default_layout, site_cfg, config, cfg_tree, way_home, input_root):

    hard_dependencies = []
    soft_dependencies = []

    if 'mirror' in config:
        mirror_fn = config['mirror']
        
        hard_dependencies.append(mirror_fn)

        try:
            with open(mirror_fn, 'r', encoding='utf-8') as mirror_file:
                html_code= mirror_file.read()
        except FileNotFound, e:
            html_code= "Mirror file not found: %s" % str(e)

        return html_code, soft_dependencies, hard_dependencies


    if 'layout' in config:
        layout = config['layout']
    else:
        layout = default_layout

    tpl_path, tpl_fname = path.split(layout)

    def url_parser( url ):
        res = urlparse( url )

        if res.netloc:
            return url

        if res.path.startswith('/'):
            url = res.path.lstrip('/')
            soft_dependencies.append(url)
            url = path.join( way_home, url )
        else:
            soft_dependencies.append(path.join(input_root, res.path))
        
        return url


    class MyTemplateLoader(jinja2.FileSystemLoader):
        def __init__(self, path):
            self.path = path
            
            super(MyTemplateLoader, self).__init__(path)

        def get_source(self, environment, template):
            tpl_fn = path.join(self.path, template)
            hard_dependencies.append(tpl_fn)

            return super(MyTemplateLoader, self).get_source(environment, template)
    
    env = jinja2.Environment( loader=MyTemplateLoader(tpl_path or './') )

    def localurl( url ):
        url = url_parser( url )
        return url

    env.filters['localurl'] = localurl

    template = env.get_template(tpl_fname)

    class MyRenderer( mistune.Renderer ):
        def link(self, link, title, text):
            link = url_parser(link)
            return super(MyRenderer, self).link(link, title, text)

        def image(self, src, title, alt_text):
            src = url_parser(src)
            return super(MyRenderer, self).image(src, title, alt_text)

    markdown = mistune.Markdown(renderer=MyRenderer(escape=True, use_xhtml=True))
    content = markdown(md_source)

    try:
        html_code = template.render( content=content, site=site_cfg, page=config, root=cfg_tree, home=way_home )
    except jinja2.TemplateNotFound, e:
        html_code = "Template not found: %s" % str(e)

    return html_code, soft_dependencies, hard_dependencies

def get_make_code(output_fn, input_dep_fn, soft_dependencies, hard_dependencies):
    
    mk_src = "%s %s : %s\n" % ( output_fn, input_dep_fn, " ".join(hard_dependencies) )
    mk_src+= "REQUISITES+=%s\n" % (" ".join(soft_dependencies))
    
    return mk_src

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('--default_layout', type=str)
    parser.add_argument('--configs', type=str)
    parser.add_argument('--site_config', type=str)
    
    args = parser.parse_args()
    input_fn = args.input

    input_fn_base, _ = path.splitext( input_fn )
    output_html_fn = input_fn_base + ".html"
    input_cfg_fn = input_fn_base + ".yml"
    input_dep_fn = input_fn_base + ".d"

    input_root, _ = path.split( input_fn_base )

    way_home = path.relpath( os.curdir, input_root )

    with open(args.site_config, 'r', encoding='utf-8') as site_cfg_file:
        site_cfg = yaml.load(site_cfg_file.read())

    cfg_fns = args.configs.strip().split(' ')

    cfg_tree, config = load_configs( cfg_fns, input_cfg_fn, input_root )

    with open(input_fn, 'r', encoding='utf-8') as md_file:
        md_source = md_file.read()

    _, md_source = mdsplit(md_source)

    rendered_source, soft_dependencies, hard_dependencies = render(md_source, args.default_layout, site_cfg, config, cfg_tree, way_home, input_root)
    mk_src = get_make_code(output_html_fn, input_dep_fn, soft_dependencies, hard_dependencies)

    with open(output_html_fn, 'w', encoding='utf-8') as html_file:
        html_file.write(rendered_source)

    with open(input_dep_fn, 'w', encoding='utf-8') as dep_file:
        dep_file.write(mk_src)
    
if __name__ == "__main__":
    main()

