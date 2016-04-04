import argparse
import yaml, re, os, json

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')

    args = parser.parse_args()

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    m = re.match( r"\s*---\s*(.*?)\s*---.*", md_source )

    if m:
        config = yaml.load( m.group(1) )
    else:
        config = dict()

    basename = os.path.splitext(args.input)[0]
    target_file = basename + ".html"
    dep_file = basename + ".d"

    config['url'] = target_file

    if 'template' in config:
        template = config['template']
        del config['template']
    else:
        template = None

    config_yaml = json.dumps(config, separators=(',', ':'))
    config_yaml = config_yaml.strip("{}")

    with open(args.output, 'w') as d_file:
        d_file.write("CF_LOCAL_%s:=%s\n" % (basename, config_yaml))

        if template:
            d_file.write("CF_TEMPLATE_%s:=%s\n" % ( basename, template ))

if __name__ == "__main__":
    main()

