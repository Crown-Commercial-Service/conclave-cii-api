# ==========================================
# STAGE 1: Build
# ==========================================
FROM ruby:3.4.9-slim AS builder

# Install necessary compilation packages for Debian-slim
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libyaml-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Set production environment flags for Bundler
ENV RAILS_ENV=production

# Enforce Gemfile.lock exactly and strip out development/test tools
RUN bundle config set --global deployment 'true' && \
    bundle config set --global without 'development test' && \
    bundle config set --global no_document 'true'

COPY Gemfile Gemfile.lock ./

# Install production gems & immediately clean up cache to minimize storage footprint
RUN bundle install --jobs 4 --retry 5 && \
    rm -rf /usr/local/bundle/cache/*.gem

# Copy the rest of the application code
COPY . .


# ==========================================
# STAGE 2: Run
# ==========================================
FROM ruby:3.4.9-slim

# Install ONLY the necessary runtime packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libpq5 \
    libyaml-0-2 && \
    rm -rf /var/lib/apt/lists/*

# Secure Debian syntax to add system group and user
RUN groupadd -r rails && useradd -r -g rails -M rails

WORKDIR /app

# Set explicit runtime environment variables
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true

# Copy gems and code from Stage 1, enforcing 'rails' user permissions on arrival
COPY --from=builder --chown=rails:rails /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=rails:rails /app /app

EXPOSE 3000

# Drop root context entirely
USER rails

CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]
