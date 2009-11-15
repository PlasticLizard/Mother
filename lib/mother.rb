require 'rubygems'
require "sinatra/base"
require "haml"
require "mongo_mapper"

#Set the root of the application for easier path specification
APP_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../")

class Mother < Sinatra::Base

   #Sinatra Configuration
   enable :raise_errors
   set :root, APP_ROOT
   set :public, "#{root}/public"
   set :logging, true
   set :static, true
   set :views, "#{root}/lib/mother/view"

   get '/' do
     haml :index
   end

end    