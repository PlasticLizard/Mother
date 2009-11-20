require 'rubygems'
require "sinatra/base"
require "haml"
require "mongo_mapper"

#Set the root of the application for easier path specification
MOTHER_APP_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../") unless defined? MOTHER_APP_ROOT

#require models
Dir[(File.join(MOTHER_APP_ROOT,"lib/mother/model/") + "*.rb")].each do |model|
  require model
end

class Mother < Sinatra::Base

   #Sinatra Configuration
   enable :raise_errors
   set :root, MOTHER_APP_ROOT
   set :public, "#{root}/public"
   set :logging, true
   set :static, true
   set :views, "#{root}/lib/mother/view"

   post '/endpoint/*/event' do
    path = params[:splat][0]
     ep = MotheredEndpoint.find_by_path(path)
     not_found unless ep
     event_json = request.body.read
     event_data = JSON.parse(event_json)
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



   get '/' do
     haml :index
   end

end