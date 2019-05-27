FROM centos:latest

ENV LANG en_US.UTF-8
ENV WORKON_HOME /var/lib/pipenv

RUN mkdir /project
WORKDIR /project

RUN yum install -y which genisoimage syslinux isomd5sum centos-release-scl
RUN yum install -y rh-python36
RUN scl enable rh-python36 "pip install -U pip" && \
    scl enable rh-python36 "pip install pipenv"

ADD Pipfile Pipfile.lock /project/
RUN scl enable rh-python36 "pipenv install"

ADD docker/tools /tools

ADD docker/entrypoint.sh /entrypoint
ENTRYPOINT ["/entrypoint"]
