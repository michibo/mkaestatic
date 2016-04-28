
from os import path
from collections import defaultdict

class dirlisttree(defaultdict):
    def __init__(self):
        def ddict():
            return dirlisttree()

        self.files = []

        super(dirlisttree, self).__init__(ddict)

    def __iter__(self):
        return iter(self.files)

    def next(self):
        pass

    __next__ = next

    def __getitem__(self, pure_path):
        if pure_path == "":
            return self

        head, tail = path.split( pure_path )
        if head == "":
            return super(dirlisttree, self).__getitem__(tail)

        return self[head][tail]

    def __str__(self):
        return "%s; %s" % (", ".join( "%s" % fn for fn in self.files ),
               ", ".join( "%s : %s" % (key,val) for key,val in self.iteritems() ))

    def append(self, content):
        self.files.append(content)

