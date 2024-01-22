# Stage 1: Build
FROM ubuntu:22.04 AS builder

ARG RUBY_VERSION=3.2.2

# Set environment variables
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive


# Install necessary packages
RUN apt-get update && apt-get -y full-upgrade && apt-get install -y \
  build-essential \
  curl \
  libpq-dev \
  libyaml-dev \
  zlib1g-dev

# Install Ruby from source
RUN curl -sSL https://cache.ruby-lang.org/pub/ruby/3.2/ruby-${RUBY_VERSION}.tar.gz | tar xz
WORKDIR /ruby-${RUBY_VERSION}
RUN ./configure --prefix=/usr/local && make -j 4 && make install

WORKDIR /app

# Install and run Bundler
COPY --chown=rails:rails Gemfile Gemfile.lock ./

RUN bundle config set --global no_document true && \
  bundle config set --global no_ri true && \
  bundle config set --global no-cache true && \
  bundle install --jobs 4 --retry 5

# Stage 2: Run
FROM ubuntu:22.04
RUN apt-get update && apt-get -y full-upgrade && apt-get install -y \
  curl \
  libpq5 \
  libyaml-0-2 \
  && rm -rf /var/cache/apt/*

RUN groupadd rails && useradd rails -g rails

WORKDIR /app
COPY --chown=rails:rails . .

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib/ruby /usr/local/lib/ruby
COPY --from=builder /app /app

EXPOSE 3000

USER rails

CMD [ "rails", "server", "-b", "0.0.0.0" ]
