import argparse
import yaml, jinja2, mistune

import os, os.path, sys

def handle_config(config_file):
    if not os.path.isfile(config_file):
        return None

    with open(config_file, 'r') as stream:
        try:
            config = yaml.load(stream)
        except yaml.YAMLError as ex:
            sys.exit(ex)
    
    if config:
        return config
    else:
        return dict()

def get_local_dirtree(template_root, web_root):
    local = dict()

    def is_allowed_dirname( dirname ):
        return not dirname.startswith(".") and dirname != template_root

    def is_allowed_filename( filename ):
        return not filename.startswith(".")

    def transform_filename( root, ext ):
        if ext == ".md":
            return dict({ ext : web_root + filename, ".html" : web_root + root + ".html" })
        else:
            return dict({ ext : web_root + filename })

    def split_path( dirpath ):
        if dirpath != ".":
            head, tail = os.path.split(dirpath)
            return split_path(head) + [tail]
        else:
            return []

    for dirpath, dirnames, filenames in os.walk("."):
        path_list = split_path(dirpath)

        l = local
        for p in path_list:
            if p in l:
                l = l[p]
            else: 
                l=None
                break

        if l == None:
            continue        

        l.update( { d : dict() for d in dirnames if is_allowed_dirname(d) } )

        for filename in filenames:
            if not is_allowed_filename(filename):
                continue

            root, ext = os.path.splitext( filename )
            entry = transform_filename( root, ext )

            l.setdefault(root, dict()).update(entry)
        
    return local

def render(template_root, config, md_source, web_root, source_root):
    input_files = set()

    def static_load( input_file ):
        input_files.add(input_file)
        return input_file
    
    env = jinja2.Environment(loader=jinja2.FileSystemLoader(template_root))
    env.filters['static_load'] = static_load

    template = env.get_template(config['layout'])

    local_keyword = "(local)"
    local_keyword_root = "(local)/"

    def link_parser( link ):
        if link.startswith(local_keyword_root):
            fn = os.path.normpath(link[len(local_keyword_root):])
            input_files.add(fn)
            link = web_root + fn
        elif link.startswith(local_keyword):
            fn = os.path.normpath(os.path.join(source_root, link[len(local_keyword):]))
            input_files.add(fn)
            link = web_root + fn

        return link

    class sttcRenderer( mistune.Renderer ):
        def link(self, link, title, text):
            link = link_parser(link)
            return super(sttcRenderer, self).link(link, title, text)

        def image(self, src, title, alt_text):
            src = link_parser(src)
            return super(sttcRenderer, self).image(src, title, alt_text)

    markdown = mistune.Markdown(renderer=sttcRenderer())
    content = markdown(md_source)

    local = get_local_dirtree(template_root, web_root)
    print(local)

    return template.render(content=content, config=config, local=local), input_files

def main():
    parser = argparse.ArgumentParser(description='Compile a static website.')
    parser.add_argument("-d", "--dependencies", action="store_true", default=False, help="build dependencies")
    parser.add_argument('input')
    parser.add_argument('output')
    parser.add_argument('--configs', default="config.yml")
    parser.add_argument('--web_root', default="")
    parser.add_argument('--templates', default="_templates")
    
    args = parser.parse_args()

    config = dict()
    config_files = args.configs.split(' ') if args.configs else []
    existing_config_files = []
    for config_file in config_files:
        c = handle_config(config_file)
        if c != None:
            config.update(c)
            existing_config_files.append(config_file)

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    source_root = os.path.dirname(args.input)
    rendered_source, input_files = render(args.templates, config, md_source, args.web_root, source_root)

    if args.dependencies:
        with open(args.output, 'w') as d_file:
            target_file = os.path.splitext(args.input)[0] + ".html"
            d_file.write("%s : %s" % ( target_file, " ".join(config_files + list(input_files)) ))
    else:
        with open(args.output, 'w') as html_file:
            html_file.write(rendered_source)
    
if __name__ == "__main__":
    main()
