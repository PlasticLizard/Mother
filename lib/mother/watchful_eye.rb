class WatchfulEye

   def initialize(options={})
      @options = options
      yield self if block_given?
    end

    def start
      @thread = Thread.new do
        loop do
          sleep(@options[:interval] || 1.0)
          self.inspection!
        end
      end

      @thread[:name] =
        @options[:thread_name] || "Mother's Watchful Eye"
    end

    def stop
      @thread.exit
    end

    def join
      @thread.join
    end

   def inspection!
     Expectation.try_expire_all
   end

  end