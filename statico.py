import argparse
import yaml, jinja2, mistune

import os, os.path, sys, re

def render(template, config, md_source:
    input_files = set()

    path, tpl_fname = os.path.split(template)

    env = jinja2.Environment( loader=jinja2.FileSystemLoader(path or './') )
    template = env.get_template(tpl_fname)

    markdown = mistune.Markdown(renderer=mistune.Renderer(use_xhtml=True))
    content = markdown(md_source)

    return template.render(content=content, config=config)

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

