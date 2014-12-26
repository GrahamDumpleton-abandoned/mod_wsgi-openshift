from __future__ import print_function

from setuptools import setup

setup_kwargs = dict(
    name = 'mod_wsgi-openshift',
    version = '1.0.0',
    description = 'OpenShift jumpstart package for Apache/mod_wsgi.',
    author = 'Graham Dumpleton',
    author_email = 'Graham.Dumpleton@gmail.com',
    maintainer = 'Graham Dumpleton',
    maintainer_email = 'Graham.Dumpleton@gmail.com',
    url = 'http://www.modwsgi.org/',
    license = 'Apache License, Version 2.0',
    platforms = [],
    download_url = None,
    classifiers= [
        'Development Status :: 6 - Mature',
        'License :: OSI Approved :: Apache Software License',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX',
        'Operating System :: POSIX :: BSD',
        'Operating System :: POSIX :: Linux',
        'Operating System :: POSIX :: SunOS/Solaris',
        'Programming Language :: Python',
        'Programming Language :: Python :: Implementation :: CPython',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Topic :: Internet :: WWW/HTTP :: WSGI',
    ],
    packages = ['mod_wsgi', 'mod_wsgi.openshift'],
    package_dir = {'mod_wsgi': 'src'},
)

setup(**setup_kwargs)
