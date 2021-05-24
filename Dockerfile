FROM phusion/passenger-ruby25:0.9.35
MAINTAINER Tiffany Rea <trea@ncsasports.org>

RUN apt-get update \
  && apt-get install -y parallel && \
  apt-get install wget

# Copy Freetds, install and cleanup
COPY freetds-1.00.21.tar.gz freetds-1.00.21.tar.gz

RUN tar -xzf freetds-1.00.21.tar.gz && \
  cd freetds-1.00.21 && \
  ./configure --prefix=/usr/local --with-tdsver=7.3 && \
  make && make install && \
  cd ../ && \
  rm freetds-1.00.21.tar.gz && \
  rm -rf freetds-1.00.21

# Install Firefox
RUN wget https://ftp.mozilla.org/pub/firefox/releases/79.0/linux-x86_64/en-US/firefox-79.0.tar.bz2 && \
  tar xvf firefox-79.0.tar.bz2 && \
  mv firefox/ /usr/lib/firefox && \
  ln -s /usr/lib/firefox /usr/bin/firefox

# Copy repo code into tmp/qa_regression
RUN mkdir /tmp/qa_regression
WORKDIR /tmp/qa_regression

COPY Gemfile Gemfile
COPY Rakefile Rakefile
COPY calc.rb calc.rb
COPY .ruby-version .ruby-version

ADD lib/ lib/
ADD test/ test/
ADD tasks/ task/
ADD config/ config/

RUN ["/bin/bash", "-l", "-c", "ruby=$(<.ruby-version) && rvm install $ruby && rvm --default use $ruby"]

ENTRYPOINT ["/bin/bash", "-c"]
