set :output, "log/cron.log" 
set :environment, "development"

every 1.minute do
  runner "UpdateRatesJob.perform_now"
end
