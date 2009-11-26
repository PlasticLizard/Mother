require File.dirname(__FILE__) + "/mothered_endpoint"

class Job
  include MongoMapper::Document
  include Mother::ModelRSS

  key :mothered_endpoint_id, ObjectId, :required=>true, :index=>true
  belongs_to :mothered_endpoint

  key :endpointPath, String, :index=>true
  
  key :name, String
  key :summary, String

  key :start_time, Time
  key :end_time, Time
  key :duration, Float

  key :endpoint_error_id, EndpointError
  belongs_to :endpoint_error

  #should be one of: idle, pending, completed, failed
  key :status, Symbol, :required=>true, :index=>true

  timestamps!  

end