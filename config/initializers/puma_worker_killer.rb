PumaWorkerKiller.config do |config|
  config.ram           = 1024 * 5  # mb
  config.frequency     = 60     # seconds
  config.percent_usage = 0.95
  config.rolling_restart_frequency = false
end
PumaWorkerKiller.start
