#!/usr/bin/env python

import os
import re
import sys

WHISKEY_HOMEDIR = os.environ['WHISKEY_HOMEDIR']
WHISKEY_DOTDIR = os.path.join(WHISKEY_HOMEDIR, '.whiskey')

CONFIG_FILE = os.path.join(WHISKEY_HOMEDIR,
        '.whiskey/apache/build/config_vars.mk')

CONFIG = {}

with open(CONFIG_FILE) as fp:
    for line in fp.readlines():
        name, value = line.split('=', 1)
        name = name.strip()
        value = value.strip()
        CONFIG[name] = value

_varprog = re.compile(r'\$(\w+|(?:\{[^}]*\}|\([^)]*\)))')

def expand_vars(value):
    if '$' not in value:
        return value

    i = 0
    while True:
        m = _varprog.search(value, i)
        if not m:
            break
        i, j = m.span(0)
        name = m.group(1)
        if name.startswith('{') and name.endswith('}'):
            name = name[1:-1]
        elif name.startswith('(') and name.endswith(')'):
            name = name[1:-1]
        if name in CONFIG:
            tail = value[j:]
            value = value[:i] + CONFIG.get(name, '')
            i = len(value)
            value += tail
        else:
            i = j

    return value

def get_vars(name):
    value = CONFIG.get(name, '')
    sub_value = expand_vars(value)
    while value != sub_value:
        value = sub_value
        sub_value = expand_vars(value)
    return sub_value.replace('/app/.whiskey', WHISKEY_DOTDIR)

CONFIG['PREFIX'] = get_vars('prefix')
CONFIG['TARGET'] = get_vars('target')
CONFIG['SYSCONFDIR'] = get_vars('sysconfdir')
CONFIG['INCLUDEDIR'] = get_vars('includedir')
CONFIG['LIBEXECDIR'] = get_vars('libexecdir')
CONFIG['BINDIR'] = get_vars('bindir')
CONFIG['SBINDIR'] = get_vars('sbindir')
CONFIG['PROGNAME'] = get_vars('progname')

_CFLAGS_NAMES = ['SHLTCFLAGS', 'CFLAGS', 'NOTEST_CPPFLAGS',
    'EXTRA_CPPFLAGS', 'EXTRA_CFLAGS']

_CFLAGS_VALUES = []

for name in _CFLAGS_NAMES:
    value = get_vars(name)
    if value:
        _CFLAGS_VALUES.append(value)

CONFIG['CFLAGS'] = ' '.join(_CFLAGS_VALUES)

if sys.argv[1] == '-q':
    print get_vars(sys.argv[2])
