
# This helper module is part of the mkaestatic program/
# script collection. mkaestatic can be used for static 
# website generation. 
#
# Author: Michael Borinsky
# Github: https://github.com/michibo/mkaestatic
# License: MIT
# Copyright 2016

import re

def mdsplit( md_source ):
    m = re.match( r"\s*(?:^---\s*$|)(.*?)\s*^---\s*$(.*)", md_source, re.DOTALL | re.MULTILINE )

    if m:
        return  m.group(1), m.group(2)
    else:
        return "{}", md_source

