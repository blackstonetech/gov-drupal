FROM centos:7
MAINTAINER Ron Williams <hello@ronwilliams.io>
ENV PATH /usr/local/src/vendor/bin/:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Install and enable repositories
Run yum -y update && \
    yum -y install \
    epel-release


# Pull base image.
FROM dockerfile/ubuntu

# Install Java.
RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jre && \
  rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# Define default command.
CMD ["bash"]

# Install base
RUN yum -y update && \
    yum -y groupinstall "Development Tools" && \
    yum -y install \
    curl \
    git \
    httpd \
    mariadb \
    msmtp \
    net-tools \
    rsync \
    tmux \
    vim \
    wget


# Install misc tools
RUN yum -y update && yum -y install \
    python-setuptools \
    rsyslog

# Install supervisor. Requires python-setuptools.
RUN easy_install \
    supervisor


# Disable services management by systemd.
RUN systemctl disable httpd.service && \
    systemctl disable rsyslog.service

# Apache config, and PHP config, test apache config
# See https://github.com/docker/docker/issues/7511 /tmp usage
COPY public/index.php /var/www/public/index.php
COPY centos-7 /tmp/centos-7/
RUN rsync -a /tmp/centos-7/etc/httpd /etc/ && \
    apachectl configtest
RUN rsync -a /tmp/centos-7/etc/php* /etc/

COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/lamp.sh /etc/lamp.sh

EXPOSE 80 443

RUN chmod +x /etc/lamp.sh
CMD ["/etc/lamp.sh"]
