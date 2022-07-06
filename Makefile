all:
	whenever --update-crontab --set environment='development'
	service cron restart
	bundle exec rails server -p 3000 -b 0.0.0.0
