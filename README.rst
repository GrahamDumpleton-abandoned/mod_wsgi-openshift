====================
MOD_WSGI (OPENSHIFT)
====================

The ``mod_wsgi-openshift`` package is a companion package for
Apache/mod_wsgi. It provides a means of building Apache/mod_wsgi support
via Docker which can be posted up to S3 and then pulled down when deploying
sites to OpenShift. This then permits the running of a custom
Apache/mod_wsgi installation on OpenShift sites, overriding the default
version which is supplied with the OpenShift Python cartridges.

Building Apache/mod_wsgi
------------------------

Check out this repository from github and run within it::

    docker build -t mod_wsgi-openshift .

This will create a Docker image with a prebuilt installation of Apache
within it. It will also contain helper scripts to aid in deploying your
WSGI application to OpenShift using ``mod_wsgi-express`` as the way of
launching Apache/mod_wsgi.

Once built you need to upload that prebuilt Apache installation up to an
S3 bucket you control. To do that run::

    docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
               -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
               -e WHISKEY_BUCKET=YOUR-BUCKET-NAME mod_wsgi-openshift

This assumes you have your AWS access and secret key defined in environment
variables of the user you are running the command as.

You should also replace ``YOUR-BUCKET-NAME`` with the actual name of the S3
bucket you have and which you are going to use to hold the tar ball for the
prebuilt version of Apache.

Integrating with OpenShift
--------------------------

In the git repository containing your WSGI application and which you intend
to push up to OpenShift now make the following changes.

First create the file ``.openshift/action_hooks/build`` containing::

    #!/usr/bin/env bash

    WHISKEY_BUCKET=${WHISKEY_BUCKET:-modwsgi.org}
    WHISKEY_PACKAGE=whiskey-openshift-centos6-apache-2.4.10.tar.gz
    WHISKEY_HOMEDIR=$OPENSHIFT_REPO_DIR

    URL=https://s3.amazonaws.com/$WHISKEY_BUCKET/$WHISKEY_PACKAGE

    curl -o $WHISKEY_HOMEDIR/$WHISKEY_PACKAGE $URL
    tar -C $WHISKEY_HOMEDIR -x -v -z -f $WHISKEY_HOMEDIR/$WHISKEY_PACKAGE
    rm -f $WHISKEY_HOMEDIR/$WHISKEY_PACKAGE

    $WHISKEY_HOMEDIR/.whiskey/scripts/mod_wsgi-openshift-build

The ``build`` script file must be set to be executable else OpenShift will
ignore it.

Replace ``modwsgi.org`` with the name of the bucket to which you uploaded
the result of the build above.

If just wanting to experiment, you can use the default ``modwsgi.org``
versions. These are located in AWS US-East. If you are deploying to
OpenShift running in a different region, you would be better off to build
your own and host your bucket in the same region as you are deploying. I
also don't guarantee the long term availability of the ``modwsgi.org``
images at this point as I don't know what the S3 costs may end up being for
hosting them and having everyone use them.

The second step is to create the file ``app.py`` containing::

    import mod_wsgi.openshift

    mod_wsgi.openshift.start('wsgi.py')

where ``wsgi.py`` is the relative file system path to the WSGI script file
containing the WSGI application entry point.

For further details on other options for referring to a WSGI application
see the ``mod_wsgi-express`` documentation as all arguments passed to
``start()`` are passed directly to ``mod_wsgi-express``.
