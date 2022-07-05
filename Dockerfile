FROM ruby:2.6.6

RUN apt-get update && apt-get install -y nodejs sqlite3

WORKDIR /app

COPY . .

COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

RUN bundle install

EXPOSE 3000
