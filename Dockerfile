FROM circleci/ruby:2.6.6

USER root

RUN apt-get --allow-releaseinfo-change update && apt-get install -y nodejs postgresql-client sqlite3

WORKDIR /app

COPY . .

COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

RUN bundle install

EXPOSE 3000
