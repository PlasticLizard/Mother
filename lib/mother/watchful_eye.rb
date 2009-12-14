require "robustthread"

class WatchfulEye

  def self.logger
    @logger || Mother::LOGGER
  end
  def self.logger=(logger)
    @logger = logger
  end

  def self.start(options={})
    WatchfulEye.new(options) do
      start()
    end
  end

  def initialize(options={}, &block)
    @options = options
    instance_eval(&block) if block_given?
  end

  def start
    WatchfulEye.logger.debug "Mother is watching..."
    RobustThread.logger = WatchfulEye.logger
    RobustThread.loop(:seconds => 3) do
      #sleep(@options[:interval] || 1.0)
      self.inspection!
    end
    WatchfulEye.logger.debug "Mother's Watchful Eye is watching on this thread:#{@thread.inspect}"
  end

  def stop
    #@thread.exit
  end

  def join
    #@thread.join
  end

  def inspection!
    WatchfulEye.logger.debug "Mother is checking for expired expectations"
    Expectation.try_expire_all
  end

end