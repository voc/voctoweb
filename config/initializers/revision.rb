APP_REVISION = if (f = Rails.root.join('REVISION')).exist?
  f.read.strip[0, 7]
else
  `git rev-parse --short HEAD 2>/dev/null`.strip.presence || 'dev'
end
