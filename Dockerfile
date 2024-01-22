# Stage 1: Build
FROM alpine:latest AS builder

ARG RUBY_VERSION=3.2.2

# Set environment variables
ENV LANG C.UTF-8

# Install necessary packages
RUN apk add build-base \
  curl \
  git \
  libpq-dev \
  yaml-dev \
  zlib-dev

# Install Ruby from source
RUN curl -sSL https://cache.ruby-lang.org/pub/ruby/3.2/ruby-${RUBY_VERSION}.tar.gz | tar xz \
  && cd ruby-${RUBY_VERSION} && ./configure --prefix=/usr/local && make -j 4 && make install

WORKDIR /app

# Install and run Bundler
COPY --chown=rails:rails Gemfile Gemfile.lock ./

RUN bundle config set --global no_document true && \
  bundle config set --global no_ri true && \
  bundle config set --global no-cache true && \
  bundle install --jobs 4 --retry 5

# Stage 2: Run
FROM alpine:latest
RUN apk update && apk upgrade && apk add \
  curl \
  libpq \
  yaml \
  && rm -rf /var/cache/apk/*

RUN addgroup -S rails && adduser -S -H -G rails rails

WORKDIR /app
COPY --chown=rails:rails . .

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib/ruby /usr/local/lib/ruby
COPY --from=builder /app /app

EXPOSE 3000

USER rails

CMD [ "rails", "server", "-b", "0.0.0.0" ]
