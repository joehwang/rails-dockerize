FROM ubuntu
# 維護者
MAINTAINER joehwang joehwang.com@gmail.com
RUN sed -i 's/archive.ubuntu.com/free.nchc.org.tw/' /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils -y \ 
build-essential libpq-dev ruby patch ruby-dev zlib1g-dev liblzma-dev curl libxss1 libappindicator1 \
libindicator7 gconf-service libasound2 libgconf-2-4 libnspr4 fonts-liberation libnss3  xdg-utils \
imagemagick libmysqlclient-dev locales tzdata
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
#設定時間
ENV TZ=Asia/Taipei
RUN echo $TZ | tee /etc/timezone
RUN mkdir /rails_app
WORKDIR /rails_app
ADD ./rails_app/Gemfile /rails_app/Gemfile
ADD ./rails_app/Gemfile.lock /rails_app/Gemfile.lock
RUN gem install bundler
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN gem install sidekiq
RUN bundle install
ADD ./rails_app /rails_app