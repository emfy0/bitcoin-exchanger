#!/bin/sh
if [ ! -f "/app/db/development.sqlite3" ]; then
  RAILS_ENV=development bundle exec rails db:create
  RAILS_ENV=development bundle exec rails db:migrate
  RAILS_ENV=development bundle exec rails db:seed
fi

RAILS_ENV=development bundle exec rails assets:clobber
RAILS_ENV=development bundle exec rails assets:precompile

rm -f tmp/pids/server.pid

$@
