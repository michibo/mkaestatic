import argparse
import yaml

from mdsplit import mdsplit

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')

    args = parser.parse_args()

    with open(args.input, 'r') as md_file:
        md_source = md_file.read()

    cfg_src, _ =    mdsplit(md_source)
    config =        yaml.load(cfg_src)
    config_yaml =   yaml.dump(config)

    with open(args.output, 'w') as yml_file:
        yml_file.write(config_yaml)

if __name__ == "__main__":
    main()

