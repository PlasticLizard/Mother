class EndpointEvent
  include MongoMapper::Document
  extend Mother::ModelRSS
  
  key :mothered_endpoint_id, ObjectId, :index=>true
  belongs_to :mothered_endpoint

  key :endpoint_path, String, :required=>true,:index=>true
  key :name, String
  key :_type, String
  
  timestamps!      
end