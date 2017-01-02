FROM arizonatribe/centos
MAINTAINER David Nunez <arizonatribe@gmail.com>

# Install mariadb and additional tools it will use
RUN yum install -y --setopt=tsflags=nodocs \
    bind-utils \
    hostname \
    psmisc \
    pwgen

RUN yum -y clean all

# Go to http://yum.mariadb.org to find the specific Centos7_amd64 version to use
ARG MARIA_VERSION=10.0.25
ENV APP_WORKING_DIR /var/lib/mysql

WORKDIR ${APP_WORKING_DIR}

# Volumes for importing, exporting and other general scripts
VOLUME ["/db-imports", "/db-exports", "/db-scripts"]

# Standard MariaDB/MySQL port being exposed for use as a container that multiple applications can connect to
EXPOSE 3306

# Scripts in this directory overlay the container's natural directory structure
COPY docker /

# Can't use bash variables in a *.repo file, so using sed to write
# the value into the copied *.repo file instead
RUN sed -i s:MARIA_VERSION:$MARIA_VERSION: /etc/yum.repos.d/MariaDB.repo

# Now install from the edited /etc/yum.repos.d/MariaDB.repo file
RUN yum install -y \
    MariaDB-server \
    MariaDB-tokudb-engine

RUN /opt/bin/permissions.sh ${APP_WORKING_DIR} \
    && /opt/bin/permissions.sh /var/log/ \
    && /opt/bin/permissions.sh /var/run/ \
    && /opt/bin/permissions.sh /db-imports \
    && /opt/bin/permissions.sh /db-exports \
    && /opt/bin/permissions.sh /db-scripts

ENTRYPOINT ["/usr/bin/start"]

CMD ["mysqld_safe"]
