FROM ruby:2.5.0
MAINTAINER Tiffany Rea <trea@ncsasports.org>

RUN apt-get update \
  && apt-get install -y parallel

RUN mkdir /tmp/qa_regression
WORKDIR /tmp/qa_regression

COPY Gemfile /tmp/qa_regression
RUN cd /tmp/qa_regression && bundle install

COPY Rakefile /tmp/qa_regression
COPY lib /tmp/qa_regression/lib
COPY test /tmp/qa_regression/test
COPY tasks /tmp/qa_regression/tasks
COPY calc.rb /tmp/qa_regression/calc.rb
COPY config /tmp/qa_regression/config

ENTRYPOINT ["/bin/bash", "-c"]
