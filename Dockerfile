# Stage 1: Build
FROM ruby:3.4.9-alpine AS builder

# Added linux-headers to satisfy the ffi gem compiler requirements
RUN apk add --no-cache \
  build-base \
  curl \
  git \
  libpq-dev \
  yaml-dev \
  zlib-dev \
  sqlite-dev \
  gcompat \
  linux-headers

WORKDIR /app

COPY --chown=rails:rails Gemfile Gemfile.lock ./

# Run Bundler
RUN bundle config set --global no_document true && \
  bundle config set --global no_ri true && \
  bundle config set --global no-cache true && \
  bundle install --jobs 4 --retry 5 && \
  rm -rf /usr/local/bundle/cache/*.gem

# Stage 2: Run
FROM ruby:3.4.9-alpine

# Install production runtime packages
RUN apk update && apk upgrade && apk add --no-cache \
  curl \
  libpq \
  yaml \
  sqlite-libs \
  && rm -rf /var/cache/apk/*

RUN addgroup -S rails && adduser -S -H -G rails rails

WORKDIR /app
COPY --chown=rails:rails . .

# Copy compiled dependencies and app code from the builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

EXPOSE 3000

USER rails

CMD [ "rails", "server", "-b", "0.0.0.0" ]
