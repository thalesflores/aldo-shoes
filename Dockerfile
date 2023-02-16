FROM ruby:3.2.1-alpine3.16 as builder

RUN apk add --no-cache --update\
  git\
  build-base\
  libpq-dev\
  libressl-dev\
  openssl-dev\
  tzdata\
  gcompat


RUN mkdir /app
WORKDIR /app

COPY Gemfile* .

ENV RAILS_ENV production

RUN bundle lock --add-platform x86_64-linux && \
  bundle install --without development test

ADD . .

FROM ruby:3.2.1-alpine3.16 as runner

ENV RAILS_ENV production

RUN apk update

RUN apk add --no-cache --update gcompat

WORKDIR /app

COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app .
