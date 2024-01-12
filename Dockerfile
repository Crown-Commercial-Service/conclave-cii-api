FROM ruby:3.2.2-alpine

WORKDIR /app

RUN apk upgrade && apk build-base nodejs && rm -rf /var/cache/apk

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
