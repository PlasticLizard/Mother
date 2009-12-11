require 'thread'

#
# EVENTS:
# :endpoint_error, args = :event_name, :error => EndpointError, :endpoint => MotheredEndpoint
# :endpoint_event, args = :event_name, :event => EndpointEvent, :Endpoint => MotheredEndpoint
# :endpoint_status_changed, args = :event_name, :previous_status=>Symbol, :new_status=>Symbol,:endpoint=>MotheredEndpoint
# :job_complete, :job_failed, args = :event_name, :job => Job
# :expectation_unmet, args = :event_name, :expectation => Expectation

class TownCrier
  class << self

    @@listeners = Hash.new { |hash,key| hash[key] = [] }
    @@configured = false
    @@lock = Mutex.new

    def proclaim(event_name, *args)
      configure() unless @@configured     
      @@lock.synchronize {
        args.unshift(event_name)
        listeners_for(event_name).each do |listener|
          listener.call(*args) if listener.respond_to?(:call)
        end

      }
    end

    def listen_for(event_name, &block)
      @@lock.synchronize {
        @@listeners[event_name] << block if block
      }
    end

    def configure(config_name = :config)
      config = RConfig.send(config_name)
      return unless config && config[:alerts]
      from_address = config.email.mothers_email_address || "mother@noreply.com"
      config[:alerts].each do |alert|
        next unless alert[:events] && alert[:people]
        alert[:events].each do |event|
          listen_for event.to_sym do |*args|
            alert[:people].each do |recipient|
              Mail.deliver do
                    from from_address
                      to recipient
                 subject "Mother sent you a letter:#{args[0]}"
                    body args.inspect
              end
            end
          end
        end
      end
      @@configured = true
    end

    private
    def listeners_for(event_name)
      @@listeners[event_name] + @@listeners[:all]
    end
  end

end