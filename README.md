# Развертывание c Docker
---
1. Setup credentials:
>__credentials.yml.enc__
>```
>base_58_key: ...
>
>```

2.
```
docker-compose up
```

# Развертывание без Docker
---

1. Setup credentials:
>__credentials.yml.enc__
>```
>base_58_key: ...
>
>```

2. Setup redis for local work
>__cable.yml__
>```
>development:
>  adapter: redis
>  url: redis://localhost:6379/1
>```

3. Bundle
```
bundle install
```
4. Create database.
```
bundle exec rails db:create
```
5. Run database migrations.
```
bundle exec rails db:migrate
```
```
bundle exec rails db:seed
```
6. Start redis
```
redis-server
```
7. Run whenever
```
whenever --update-crontab --set environment='development'
```
8. Restart cron service
```
service cron restart
```
9. Start rails server.
```
bundle exec rails s
```
