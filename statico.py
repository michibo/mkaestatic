import argparse
import yaml, jinja2, mistune

import os, os.path, sys

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
        path_tree = val

    head, tail = os.path.split( pure_fn )
    get_pt_leave( path_tree, head )[tail] = val    

def render(template, config, md_source):
    path, tpl_fname = os.path.split(template)

    env = jinja2.Environment( loader=jinja2.FileSystemLoader(path or './') )
    template = env.get_template(tpl_fname)

    markdown = mistune.Markdown(renderer=mistune.Renderer(escape=True,use_xhtml=True))
    content = markdown(md_source)

    pages = config['pages']
    del config['pages']

    ######## translate urls to relative ##########
    # add information about how deep the document is in the file tree compared to root
    config['depth'] = len(config['url'].split('/')) - 2
    config['static_prefix'] = '../' * config['depth']
    # remove leading forward slash in url paths
    for i in range(len(pages)-1):
        #print pages[i]
        pages[i]['url'] = pages[i]['url'][1:]
        #print pages[i]['url']
    # move through tree and remove forward slashes in subdir urls
    subdirs = config.get('subdirs', [])
    for subdir in subdirs.keys():
        for i in range(len(subdirs[subdir]['pages'])-1):
            print config['subdirs'][subdir]['pages'][i]['url']
            config['subdirs'][subdir]['pages'][i]['url'] = \
                config['subdirs'][subdir]['pages'][i]['url'][1:]
            print config['subdirs'][subdir]['pages'][i]['url']
    # TODO: works only on first level, use generators! 
    #print config

    return template.render(content=content, page=config, pages=pages)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('--configs', type=str)
    
    args = parser.parse_args()

    cfg_fns = args.configs.split(' ')

    cfg_tree = ddict()

    for cfg_fn in cfg_fns:
        if os.path.isabs(cfg_fn):
            raise ValueError('Error: You cannot use absolute pathshere: %s' % cfg_fn)

        with open(cfg_fn, 'r') as cfg_file:
            cfg = yaml.load(cfg_file.read())

        pure_fn, _ = os.path.splitext( cfg_fn )

        set_pt_leave( cfg_tree, pure_fn, cfg )

    print cfg_tree

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    _, md_source = mdsplit(md_source)

    rendered_source = render(args.template, config, md_source)

    with open(args.output, 'w') as html_file:
        html_file.write(rendered_source)
    
if __name__ == "__main__":
    main()

