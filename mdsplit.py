import re

def mdsplit( md_source ):
    m = re.match( r"\s*(?:---\s+|)(.*?)\s+---\s+(.*)", md_source )

    if m:
        return  m.group(1), m.group(2)
    else:
        return "{}", md_source

