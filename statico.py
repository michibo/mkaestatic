import argparse
import yaml, jinja2, mistune

import os, os.path, sys, re

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
    parser.add_argument('--config', default="")
    parser.add_argument('--template')
    
    args = parser.parse_args()

    config = yaml.load(args.config)

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    m = re.match( r"\s*---\s*.*?\s*---\s*(.*)", md_source )
    if m:
        md_source = m.group(1)

    rendered_source = render(args.template, config, md_source)

    with open(args.output, 'w') as html_file:
        html_file.write(rendered_source)
    
if __name__ == "__main__":
    main()

