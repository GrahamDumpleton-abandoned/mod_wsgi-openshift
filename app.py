import mod_wsgi.openshift

mod_wsgi.openshift.start('--with-newrelic-platform', '--processes', '5',
        '--threads', '2', '--keep-alive-timeout', '30')
