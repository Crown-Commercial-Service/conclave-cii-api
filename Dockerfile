FROM ubuntu:22.04

# Set environment variables
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get -y full-upgrade && apt-get install -y \
  build-essential \
  curl \
  bash \
  libpq-dev \
  nodejs \
  gpg

# Install Node.js
# RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
#   apt-get install -y nodejs

# Add RVM's public key and install Ruby
RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
  curl -sSL https://get.rvm.io | bash -s stable --ruby=3.2.2

# # Source RVM scripts and install Bundler
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh && gem install bundler"

COPY Gemfile Gemfile.lock ./
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh && bundle install --jobs 20 --retry 5"

COPY . .

EXPOSE 3000

CMD [ "/bin/bash", "-l", "-c", "source /etc/profile.d/rvm.sh && rails server -b 0.0.0.0" ]
