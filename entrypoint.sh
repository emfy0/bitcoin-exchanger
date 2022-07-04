#!/bin/sh

if [ ! -f "/app/db/development.sqlite3" ]; then
  RAILS_ENV=development bundle exec rails db:create

  RAILS_ENV=development bundle exec rails db:migrate

  RAILS_ENV=development bundle exec rails db:seed
fi

whenever --update-crontab --set environment='development'

service cron stop

service cron start

rm -f tmp/pids/server.pid

$@
