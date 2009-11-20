class EndpointEvent
  include MongoMapper::Document

  key :mothered_endpoint_id, ObjectId, :index=>true
  key :name, String
  #Code here
end