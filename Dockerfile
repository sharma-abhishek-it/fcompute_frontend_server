FROM ruby:2.2.0

RUN gem install bundler

RUN mkdir /gems

ADD Gemfile /gems/
ADD Gemfile.lock /gems/

RUN cd /gems && bundle install --jobs=8

RUN rm -rf /gems
