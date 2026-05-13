FROM ruby:3.4.9-bookworm

COPY . /test/

WORKDIR /test/

ENV BUNDLE_GEMFILE=Gemfile8
ENV PUPPET_FORGE=https://forge.puppet.com

RUN bundle install --jobs=4 --retry=3
# RUN bundle exec rake lint
# RUN bundle exec rake spec:unit