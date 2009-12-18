$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require "sinatra/base"
require "mongo_mapper"
require "json"
require "active_support"
require "mail"
require "rconfig"
require "logger"
require "robustthread"

#require helpers / utilities
require "mother/model/model_rss"
require "mother/town_crier"
require "mother/watchful_eye"

#require models
require "mother/model/endpoint_error"
require "mother/model/endpoint_event"
require "mother/model/expectation"
require "mother/model/job"
require "mother/model/job_events"
require "mother/model/model_rss"
require "mother/model/mothered_endpoint"


module Mother
  class Application < Sinatra::Base

    helpers do
      def absolute_uri(path)
        env["rack.url_scheme"] + "://" + File.join(env["HTTP_HOST"] || env["SERVER_NAME"],path)
      end

      def get_endpoint_and_event(event_class)
        path = params[:splat][0]
        ep = MotheredEndpoint.find_by_path(path) || MotheredEndpoint.create(:path=>path)
        evt_data = JSON.parse(request.body.read)
        [ep,event_class.new(evt_data)]
      end
    end

    get '/endpoint/all/events.rss' do
      options = {}
      options[:max_results] = Integer(params[:max_results]) if params[:max_results]
      options[:feed_link] = request.url
      options[:item_link_template] = absolute_uri "endpoint/<%=model.endpoint_path%>/event/<%=model.id%>"
      EndpointEvent.to_rss options
    end

    post '/endpoint/*/job' do
      ep, event = get_endpoint_and_event JobStartedEvent
      job = ep.create_job(event)
      ep.add_event(event)
      job.id.to_s
    end

    post '/endpoint/*/job/:job_id/complete' do
      ep, event = get_endpoint_and_event(JobCompletedEvent)
      job = Job.find(params[:job_id])
      not_found unless job
      job.complete(event)
      job.save
      event.job_id = job.id
      ep.add_event(event)
    end

    post '/endpoint/*/job/complete' do
      ep,event = get_endpoint_and_event JobCompletedEvent
      js = JobStartedEvent.new :name=>event.name
      job = ep.create_job js
      job.complete(event)
      job.save
      event.job_id = job.id
      ep.add_event(event)
    end

    post '/endpoint/*/job/:job_id/failed' do
      ep,event = get_endpoint_and_event JobFailedEvent
      job = Job.find(params[:job_id])
      not_found unless job
      job.fail(event)
      job.save
      event.job_id = job.id
      ep.add_event(event)
    end

    post '/endpoint/*/job/failed' do
      ep,event = get_endpoint_and_event JobFailedEvent
      js = JobStartedEvent.new :name=>event.name
      job = ep.create_job js
      job.fail(event)
      job.save
      event.job_id = job.id
      ep.add_event(event)
    end

    post '/endpoint/*/event' do
      ep,event = get_endpoint_and_event EndpointEvent
      ep.add_event event
      ep.id.to_s
    end

    put '/endpoint/*/status' do
      path = params[:splat][0]
      ep = MotheredEndpoint.find_by_path(path)
      not_found unless ep
      status = request.body.read
      #very crude regex to detect JSON, rather than plain string
      status = JSON.parse(status) if /^[\[|\{]/ =~ status
      ep.status = status
      ep.save
    end

    put '/endpoint/*' do
      path = params[:splat][0]
      ep = MotheredEndpoint.find_by_path(path) || MotheredEndpoint.new
      ep.from_json(request.body.read)
      ep.path = path
      ep.save
      path
    end

    configure do
      #Set the root of the application for easier path specification
      MOTHER_APP_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../")

      #set path for config files
      RConfig.config_paths = ["#{MOTHER_APP_ROOT}/config"]
      CONFIG = RConfig.config || {}

      MongoMapper.database = CONFIG.database || "mother"
      MongoMapper.ensure_indexes!
      
      if CONFIG.email
        Mail.defaults do
          smtp( (CONFIG.email.server || 'localhost'), (CONFIG.email.port || 25) )
        end
      end

      #Sinatra Configuration
      disable :reload
      enable :raise_errors
      set :root, MOTHER_APP_ROOT
      set :logging, true
      set :static, false
      #set :public, "#{root}/public"
      #set :views, "#{root}/lib/mother/view"

      Mother::LOGGER = Logger.new(RConfig.config.log_file || "mother.log", 10, 1024000)
      Mother::LOGGER.level = eval(RConfig.config.log_level) if RConfig.config.log_level
      Time.zone = RConfig.config.time_zone || "PST"
      WATCHFUL_EYE = WatchfulEye.start(:interval=>0.5)
    end

  end
end

