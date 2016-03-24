import argparse
import json, jinja2, mistune

import os, os.path, sys

def render(template, config, md_source, web_root, source_root):
    input_files = set()

    path, tpl_fname = os.path.split(template)

    env = jinja2.Environment( loader=jinja2.FileSystemLoader(path or './') )

    def static_load( input_file ):
        input_files.add(input_file)
        return input_file

    env.filters['static_load'] = static_load

    template = env.get_template(tpl_fname)

    local_keyword = "{local}"
    local_keyword_root = "{local}/"

    def link_parser( link ):
        if link.startswith(local_keyword):
            if link.startswith(local_keyword_root):
                fn = os.path.normpath(link[len(local_keyword_root):])
            else:
                fn = os.path.normpath(os.path.join(source_root, link[len(local_keyword):]))

            link = web_root + fn

        return link

    class MyRenderer( mistune.Renderer ):
        def link(self, link, title, text):
            link = link_parser(link)
            return super(MyRenderer, self).link(link, title, text)

        def image(self, src, title, alt_text):
            src = link_parser(src)
            return super(MyRenderer, self).image(src, title, alt_text)

    markdown = mistune.Markdown(renderer=MyRenderer(use_xhtml=True))
    content = markdown(md_source)

    return template.render(content=content, config=config), input_files

def main():
    parser = argparse.ArgumentParser(description='Compile a static website.')
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('--config', default="")
    parser.add_argument('--web_root', default="")
    parser.add_argument('--template')
    
    args = parser.parse_args()

    config = json.loads(args.config)

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    source_root = os.path.dirname(args.input)
    rendered_source, input_files = render(args.template, config, md_source, args.web_root, source_root)

    with open(args.output, 'w') as html_file:
        html_file.write(rendered_source)
    
if __name__ == "__main__":
    main()

