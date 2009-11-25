class EndpointEvent
  include MongoMapper::Document
  extend Mother::ModelRSS
  
  key :mothered_endpoint_id, ObjectId, :index=>true
  key :endpoint_path, String, :index=>true
  key :name, String
  key :_type, String

  timestamps!      
end