require 'rubygems'
require "sinatra/base"
require "haml"
require "mongo_mapper"

#Set the root of the application for easier path specification
MOTHER_APP_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../") unless defined? MOTHER_APP_ROOT

require File.join(MOTHER_APP_ROOT,"lib/mother/model/mother_model")
require File.join(MOTHER_APP_ROOT,"lib/mother/model/letter_home")

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

   post '/endpoint/:id/status' do
      "id: " + params[:id].to_s
   end

    post '/endpoint/*/status' do
      params[:splat].to_s
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