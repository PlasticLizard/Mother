RConfig.config_paths = [Rails.root.join('config')]

module Mother
  LOGGER = Rails.logger
  CONFIG = RConfig.config || {}
end


if RConfig.config.email
  Mail.defaults do
    smtp( (RConfig.config.email.server || 'localhost'), (RConfig.config.email.port || 25) )
  end
end


Time.zone = RConfig.config.time_zone || "PST"
#WATCHFUL_EYE = WatchfulEye.start(:interval=>0.5)


if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    #WATCHFUL_EYE = WatchfulEye.start(:interval=>0.5) if forked
  end
end