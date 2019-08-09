FROM phusion/passenger-ruby25:0.9.35
MAINTAINER Tiffany Rea <trea@ncsasports.org>

RUN apt-get update \
  && apt-get install -y parallel

# Copy Freetds, install and cleanup
COPY freetds-1.00.21.tar.gz freetds-1.00.21.tar.gz

RUN tar -xzf freetds-1.00.21.tar.gz && \
  cd freetds-1.00.21 && \
  ./configure --prefix=/usr/local --with-tdsver=7.3 && \
  make && make install && \
  cd ../ && \
  rm freetds-1.00.21.tar.gz && \
  rm -rf freetds-1.00.21

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
