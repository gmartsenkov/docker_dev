FROM ubuntu-debootstrap:trusty
MAINTAINER Georgi Martsenkov

RUN locale-gen en_US.UTF-8

ENV HOME /root
ENV PATH $HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV NODE_VERSION 7.4
ENV CONFIGURE_OPTS --disable-install-doc

RUN apt-get update && apt-get install -y \
      build-essential \
      checkinstall \
      libssl-dev \
      bash \
      npm \
      sudo \
      libpng-dev \
      alien \
      libaio1 \
      libaio-dev \
      libxml2-dev \
      libxslt1-dev \
      libxml2-dev \
      libxslt1-dev \
      git \
      curl \
      libpq-dev \
      postgresql \
      postgresql-contrib \
      apt-transport-https\
      nodejs \
      sqlite3 \
      vim \
      tmux \
      wget \
      libsqlite3-dev ;

RUN apt-get -q update \
  && DEBIAN_FRONTEND=noninteractive apt-get -q -y install wget \
  && apt-get -q clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -O - https://github.com/sstephenson/rbenv/archive/master.tar.gz \
  | tar zxf - \
  && mv rbenv-master $HOME/.rbenv
RUN wget -O - https://github.com/sstephenson/ruby-build/archive/master.tar.gz \
  | tar zxf - \
  && mkdir -p $HOME/.rbenv/plugins \
  && mv ruby-build-master $HOME/.rbenv/plugins/ruby-build

RUN echo 'eval "$(rbenv init -)"' >> $HOME/.profile
RUN echo 'eval "$(rbenv init -)"' >> $HOME/.bashrc

RUN apt-get update -q \
  && apt-get -q -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
  && rbenv install 2.3.3 \
  && rbenv install 2.2.3 \
  && rbenv install 2.2.5 \
  && rm -rf /var/lib/apt/lists

RUN rbenv global 2.2.5
RUN gem install --no-ri --no-rdoc bundler
RUN rbenv global 2.2.3
RUN gem install --no-ri --no-rdoc bundler
RUN rbenv global 2.3.3
RUN gem install --no-ri --no-rdoc bundler
RUN rbenv rehash

# Oracle stuff
RUN mkdir -p /opt/oracle
COPY ./vendor/*.rpm /opt/oracle/

ENV ORACLE_HOME /usr/lib/oracle/12.1/client64
ENV LD_LIBRARY_PATH $ORACLE_HOME/lib/:$LD_LIBRARY_PATH
ENV NLS_LANG American_America.UTF8
ENV PATH $ORACLE_HOME/bin:$PATH

# Install Oracle Client
RUN alien -i /opt/oracle/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm \
  && alien -i /opt/oracle/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm \
  && alien -i /opt/oracle/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm

# Install nvm
RUN ln -s /usr/bin/nodejs /usr/bin/node;
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | bash

# invoke nvm to install node
RUN cp -f ~/.nvm/nvm.sh ~/.nvm/nvm-tmp.sh; \
    echo "nvm install 7.4; nvm alias default 7.4" >> ~/.nvm/nvm-tmp.sh; \
    sh ~/.nvm/nvm-tmp.sh; \
    rm ~/.nvm/nvm-tmp.sh;

# Install crystal
RUN curl http://dist.crystal-lang.org/apt/setup.sh | bash

RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54; \
        echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list; \
        apt-get update; \
        sudo apt-get install crystal;
