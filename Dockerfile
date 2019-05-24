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
RUN cd /tmp/qa_regression

COPY Gemfile /tmp/qa_regression
COPY Rakefile /tmp/qa_regression
COPY lib /tmp/qa_regression/lib
COPY test /tmp/qa_regression/test
COPY tasks /tmp/qa_regression/tasks
COPY calc.rb /tmp/qa_regression/calc.rb
COPY config /tmp/qa_regression/config

COPY .ruby-version /tmp/qa_regression
RUN ["/bin/bash", "-l", "-c", "ruby=$(<.ruby-version) && rvm install $ruby && rvm --default use $ruby"]

ENTRYPOINT ["/bin/bash", "-c"]
