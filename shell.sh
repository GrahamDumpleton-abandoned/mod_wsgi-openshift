#!/usr/bin/env bash

# This script will run an interactive bash shell.

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

# OpenShift will have passed through any environment variables set in the
# OpenShift config. Here we are going to look for any statically defined
# environment variables provided by the user as part of the actual
# application. These will have been placed in the '.whiskey/user_vars'
# directory. The name of the file corresponds to the name of the
# environment variable and the contents of the file the value to set the
# environment variable to. Each of the environment variables is set and
# exported.

envvars=

for name in `ls .whiskey/user_vars`; do
    export $name=`cat .whiskey/user_vars/$name`
    envvars="$envvars $name"
done

# Run any user supplied script to be run to set, modify or delete the
# environment variables.

if [ -x .whiskey/action_hooks/deploy-env ]; then
    echo " -----> Running .whiskey/action_hooks/deploy-env"
    .whiskey/action_hooks/deploy-env
fi

# Go back and reset all the environment variables based on additions or
# changes. Unset any for which the environment variable file no longer
# exists, albeit in practice that is probably unlikely.

for name in `ls .whiskey/user_vars`; do
    export $name=`cat .whiskey/user_vars/$name`
done

for name in $envvars; do
    if test ! -f .whiskey/user_vars/$name; then
        unset $name
    fi
done

# Now finally run bash.

exec bash
