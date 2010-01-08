class EndpointEvent
  include MongoMapper::Document
  
  key :endpoint_id, ObjectId, :index=>true, :required=>true
  belongs_to :endpoint

  key :endpoint_path, String, :required=>true,:index=>true
  key :name, String
  key :_type, String

  key :expect_next_at, Time
  
  timestamps! 
  
end