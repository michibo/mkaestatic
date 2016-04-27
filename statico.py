import argparse
import yaml, jinja2, mistune

import sys

import os
from os import path

from collections import defaultdict

from mdsplit import mdsplit

def ddict():
    return defaultdict(ddict)

def get_pt_leave( path_tree, pure_fn ):
    if pure_fn == "":
        return path_tree

    head, tail = os.path.split( pure_fn )
    return get_pt_leave( path_tree, head )[tail]

def set_pt_leave( path_tree, pure_fn, val ):
    if pure_fn == "":
        raise ValueError('Error: filename missing')

    head, tail = os.path.split( pure_fn )
    get_pt_leave( path_tree, head )[tail] = val

def load_configs( config_fns, input_cfg_fn, input_root ):
    cfg_tree = ddict()

    for cfg_fn in config_fns:
        if path.isabs(cfg_fn):
            raise ValueError('Error: You cannot use absolute paths here: %s' % cfg_fn)

        cfg_fn_base, _ = path.splitext( cfg_fn )
        target_fn      = cfg_fn_base + ".html"
        url            = path.relpath( target_fn, input_root )

        with open(cfg_fn, 'r') as cfg_file:
            cfg = yaml.load(cfg_file.read())

        cfg['url'] = url

        if 'title' not in cfg:
            _, cfg['title'] = path.split(cfg_fn_base)

        if cfg_fn == input_cfg_fn:
            config = cfg

        pure_fn, _ = path.splitext( cfg_fn )

        set_pt_leave( cfg_tree, pure_fn, cfg )

    return cfg_tree, config

def render(md_source, default_layout, config, site_cfg, cfg_tree, way_home):
    if 'layout' in config:
        layout = config['layout']
    else:
        layout = default_layout

    tpl_path, tpl_fname = path.split(layout)

    def url_parser( url ):
        if url.startswith('/') and not url.startswith('//'):
            url = string.lstrip(url, '/')
            url = path.join( way_home, url )

        return url

    env = jinja2.Environment( loader=jinja2.FileSystemLoader(tpl_path or './') )

    def local_url( url ):
        url = url_parser( url )
        return url 

    env.filters['local_url'] = local_url

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

    return template.render( content=content, site=site_cfg, page=config, root=cfg_tree, home=way_home )

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('--default_layout', type=str)
    parser.add_argument('--configs', type=str)
    parser.add_argument('--site_config', type=str)
    
    args = parser.parse_args()
    input_fn = args.input

    input_fn_base, _ = path.splitext( input_fn )
    input_cfg_fn = input_fn_base + ".yml"

    input_root, _ = path.split( input_fn_base )

    way_home = path.relpath( os.curdir, input_root )

    with open(args.site_config, 'r') as site_cfg_file:
        site_cfg = yaml.load(site_cfg_file.read())

    cfg_fns = args.configs.split(' ')

    cfg_tree, config = load_configs( cfg_fns, input_cfg_fn, input_root )

    with open(input_fn, 'r') as md_file:
        md_source = md_file.read()

    _, md_source = mdsplit(md_source)

    rendered_source = render(md_source, args.default_layout, site_cfg, config, cfg_tree, way_home)

    with open(args.output, 'w') as html_file:
        html_file.write(rendered_source)
    
if __name__ == "__main__":
    main()

