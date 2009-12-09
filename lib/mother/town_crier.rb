require 'thread'

#
# EVENTS:
# :endpoint_error, args = :error => EndpointError, :endpoint => MotheredEndpoint
# :endpoint_event, args = :event => EndpointEvent, :Endpoint => MotheredEndpoint
# :endpoint_status_changed, args = :previous_status=>Symbol, :new_status=>Symbol,:endpoint=>MotheredEndpoint
# :job_complete, :job_failed, args = :job => Job
# :expectation_unmet, args = :expectation => Expectation

class TownCrier
  class << self

      @@listeners = Hash.new { |hash,key| hash[key] = [] }
      @@lock = Mutex.new

    def proclaim(event_name, *args)
      @@lock.synchronize {
        listeners_for(event_name).each do |listener|
          listener.call(args) if listener.respond_to?(:call)
        end

      }
    end

    def listen_for(event_name, &block)
      @@lock.synchronize {
        @@listeners[event_name] << block if block_provided?
      }
    end

    private
    def listeners_for(event_name)
      @@listeners[event_name] + @@listeners[:all]
    end
  end

end