
# This python program is part of the mkaestatic program/
# script collection. mkaestatic can be used for static 
# website generation. 
#
# configo.py reads the header attributes of markdown files and 
# writes them into make friendly auxillary files. 
# 
# Author: Michael Borinsky
# Github: https://github.com/michibo/mkaestatic
# License: MIT
# Copyright 2016

import argparse

from codecs import open

import yaml

from os import path

from mdsplit import mdsplit

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')

    args = parser.parse_args()
    input_fn = args.input

    input_fn_base, _ = path.splitext( input_fn )
    output_cfg_fn = input_fn_base + ".yml"

    with open(args.input, 'r', encoding='utf-8') as md_file:
        md_source = md_file.read()

    cfg_src, _ =    mdsplit(md_source)
    config =        yaml.load(cfg_src)
    config_yaml =   yaml.dump(config)

    if path.exists( output_cfg_fn ):
        with open(output_cfg_fn, 'r', encoding='utf-8') as yml_file_ro:
            if yml_file_ro.read() != config_yaml:
                overwrite = True
            else:
                overwrite = False
    else:
        overwrite = True

    if overwrite:
        with open(output_cfg_fn, 'w', encoding='utf-8') as yml_file:
            yml_file.write(config_yaml)

if __name__ == "__main__":
    main()

