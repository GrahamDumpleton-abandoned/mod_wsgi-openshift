from __future__ import print_function

import os
import sys

def start(*args):
    bindir = os.path.join(os.environ['VIRTUAL_ENV'], 'bin')
    program = os.path.join(bindir, 'mod_wsgi-openshift-start')

    name = os.path.basename(sys.executable) + ' -u ' + ' '.join(sys.argv)

    args = ['--process-name', name] + list(args)

    print(' -----> Starting mod_wsgi-express')
    print('%s %s' % (program, args))

    os.execl(program, name, *args)
