import argparse
import json, jinja2, mistune

import os, os.path, sys

def render(template_root, config, md_source, web_root, source_root):
    input_files = set()

    class MyTemplateLoader(jinja2.FileSystemLoader):
        def __init__(self, path):
            self.path = path
            
            super(MyTemplateLoader, self).__init__(path)

        def get_source(self, environment, template):
            path = os.path.join(self.path, template)

            input_files.add(path)

            return super(MyTemplateLoader, self).get_source(environment, template)
    
    env = jinja2.Environment(loader=MyTemplateLoader(template_root))

    def static_load( input_file ):
        input_files.add(input_file)
        return input_file

    env.filters['static_load'] = static_load

    template = env.get_template(config['layout'])

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
    parser.add_argument("-d", "--dependencies", action="store_true", default=False, help="build dependencies")
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('--config', default="")
    parser.add_argument('--web_root', default="")
    parser.add_argument('--templates', default="_templates")
    
    args = parser.parse_args()

    config = json.loads(args.config)

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    source_root = os.path.dirname(args.input)
    rendered_source, input_files = render(args.templates, config, md_source, args.web_root, source_root)

    if args.dependencies:
        with open(args.output, 'w') as d_file:
            basename = os.path.splitext(args.input)[0]
            target_file = basename + ".html"
            dep_file = basename + ".d"
            d_file.write("%s %s : %s\n" % ( target_file, dep_file, " ".join(input_files) ))
    else:
        with open(args.output, 'w') as html_file:
            html_file.write(rendered_source)
    
if __name__ == "__main__":
    main()

