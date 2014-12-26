FROM centos:centos6

RUN curl -o epel-release-6-8.noarch.rpm \
    http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN rpm -Uvh epel-release-6*.rpm

RUN yum -y install libssl1.0.0 curl gcc file \
        libc6-dev libssl-dev xz-utils zlib1g-dev libsqlite3-dev \
        pcre pcre-devel python-pip python-virtualenv tar

WORKDIR /app

RUN pip install zc.buildout boto
RUN pip install -U setuptools

RUN buildout init

COPY buildout.cfg /app/

RUN buildout -v -v

RUN mkdir -p /app/.whiskey/scripts

COPY build.sh /app/.whiskey/scripts/mod_wsgi-openshift-build
COPY start.sh /app/.whiskey/scripts/mod_wsgi-openshift-start
COPY shell.sh /app/.whiskey/scripts/mod_wsgi-openshift-shell

RUN mv /app/.whiskey/apache/bin/apxs /app/.whiskey/apache/bin/apxs-perl
COPY apxs.py /app/.whiskey/apache/bin/apxs

COPY jumpstart /app/.whiskey/jumpstart

RUN tar cvfz whiskey-openshift-centos6-apache-2.4.10.tar.gz \
    .whiskey/apache .whiskey/apr-util .whiskey/apr .whiskey/scripts \
    .whiskey/jumpstart

RUN ls -las /app/whiskey-openshift-centos6-apache-2.4.10.tar.gz

CMD s3put --access_key "$AWS_ACCESS_KEY_ID" \
          --secret_key "$AWS_SECRET_ACCESS_KEY" \
          --bucket "$WHISKEY_BUCKET" --prefix /app/ \
          /app/whiskey-openshift-centos6-apache-2.4.10.tar.gz
