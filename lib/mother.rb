$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require "sinatra/base"
require "haml"
require "mongo_mapper"

#Should load this from config
MongoMapper.database = "mother"
#Set the root of the application for easier path specification
MOTHER_APP_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../") unless defined? MOTHER_APP_ROOT

#require models
require "mother/model/model_rss"
Dir[(File.join(MOTHER_APP_ROOT,"lib/mother/model/") + "*.rb")].each do |model|
  require model
end

module Mother
  class Application < Sinatra::Base

    #Sinatra Configuration
    enable :raise_errors
    set :root, MOTHER_APP_ROOT
    set :public, "#{root}/public"
    set :logging, true
    set :static, true
    set :views, "#{root}/lib/mother/view"

    helpers do
      def absolute_uri(env,path)
        env["rack.url_scheme"] + "://" + File.join(env["HTTP_HOST"] || env["SERVER_NAME"],path)
      end
    end

    get '/endpoint/all/events.rss' do
      options = {}
      options[:max_results] = Integer(params[:max_results]) if params[:max_results]
      options[:feed_link] = request.url
      options[:item_link_template] =  lambda { |d| absolute_uri(env,'endpoint/%s/event/%s' % [d.endpoint_path,d.id])}
      EndpointEvent.to_rss options
    end

    post '/endpoint/*/event' do
      path = params[:splat][0]
      ep = MotheredEndpoint.find_by_path(path) || MotheredEndpoint.create(:path=>path)
      event_data = JSON.parse(request.body.read)
      event_data['endpoint_path'] = path
      event = ep.endpoint_events.build event_data
      event.save
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

  end
end