#!/usr/bin/env bash

# This is the script that prepares the Python application to be run.
#
# Under OpenShift this would be triggered from the OpenShift build hook.
# As OpenShift does all the preparation of the image, only a build hook
# to be run after all the packages have been installed can be provided.
# If if it was necessary to run actions prior to pip being run to install
# packages, then you would need to define a pre-build hook for OpenShift.

# Ensure that any failure within this script or a user provided script
# causes this script to fail immediately. This eliminates the need to
# check individual statuses for anything which is run and prematurely
# exit. Note that the feature of bash to exit in this way isn't
# foolproof. Ensure that you heed any advice in:
#
#   http://mywiki.wooledge.org/BashFAQ/105
#   http://fvue.nl/wiki/Bash:_Error_handling
#
# and use best practices to ensure that failures are always detected.
# Any user supplied scripts should also use this failure mode.

set -eo pipefail

# Mark what runtime this is.

WHISKEY_RUNTIME=openshift
export WHISKEY_RUNTIME

# Set up the home directory for the application.

WHISKEY_HOMEDIR=$OPENSHIFT_REPO_DIR
export WHISKEY_HOMEDIR

# Set up the bin directory where our scripts will be.

WHISKEY_BINDIR=$VIRTUAL_ENV/bin
export WHISKEY_BINDIR

# Override LD_LIBRARY_PATH so shared libraries can be found.

LD_LIBRARY_PATH=$WHISKEY_HOMEDIR/.whiskey/apr/lib:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=$WHISKEY_HOMEDIR/.whiskey/apr-util/lib:$LD_LIBRARY_PATH

export LD_LIBRARY_PATH

# Make sure we are in the correct working directory for the application.

cd $WHISKEY_HOMEDIR

# Copy the Apache executables into the Python directory so they can
# be found without working out how to override the PATH.

cp $WHISKEY_HOMEDIR/.whiskey/apache/bin/apxs $WHISKEY_BINDIR/apxs
cp $WHISKEY_HOMEDIR/.whiskey/apache/bin/httpd $WHISKEY_BINDIR/httpd
cp $WHISKEY_HOMEDIR/.whiskey/apache/bin/rotatelogs $WHISKEY_BINDIR/rotatelogs
cp $WHISKEY_HOMEDIR/.whiskey/apache/bin/ab $WHISKEY_BINDIR/ab

# Copy the mod_wsgi OpenShift scripts into the Python bin directory
# so they are found without working out how to override the PATH.

cp .whiskey/scripts/mod_wsgi-openshift-start $WHISKEY_BINDIR
cp .whiskey/scripts/mod_wsgi-openshift-shell $WHISKEY_BINDIR

# Build and install mod_wsgi.

pip install -U mod_wsgi

# Build and install mod_wsgi jumpstart package for OpenShift.

pip install -U .whiskey/jumpstart

# Create the '.whiskey/user_vars' directory for storage of user defined
# environment variables if it doesn't already exist. These can be
# created by the user from any hook script. The name of the file
# corresponds to the name of the environment variable and the contents
# of the file the value to set the environment variable to.

mkdir -p .whiskey/user_vars

# Run any user supplied script to run after installing any application
# dependencies. This is to allow any application specific setup scripts
# to be run, such as 'collectstatic' for a Django web application. The
# script must be executable in order to be run.

if [ -x .whiskey/action_hooks/build ]; then
    echo " -----> Running .whiskey/action_hooks/build"
    .whiskey/action_hooks/build
fi

# We need to ensure that the Python virtual environment is relocatable
# after anything has been installed in it. This is because each gear
# will actually take a copy of everything and run under a different
# directory path.
#
# In doing this we need to detect whether it is old style Python virtual
# environment or pyvenv as each need to be dealt with differently.

function pyvenv-relocatable {
  pushd "$1" > /dev/null

  vdir=$(cd "$1" && pwd)
  for zf in $(grep -l -r "#\!$vdir/venv/bin/" . ); do
    sed --follow-symlinks -i "s;#\!$vdir/venv/bin/;#\!/usr/bin/env ;" "$zf"
  done

  popd > /dev/null
}

if test -f $VIRTUAL_ENV/pyvenv.cfg; then
    pyvenv-relocatable $VIRTUAL_ENV
else
    virtualenv --relocatable $VIRTUAL_ENV
fi

# Clean up any temporary files, including the results of checking out
# any source code repositories when doing a 'pip install' from a VCS.

rm -rf .whiskey/tmp
