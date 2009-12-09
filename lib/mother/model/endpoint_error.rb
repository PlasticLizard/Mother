class EndpointError
  include MongoMapper::Document
  include Mother::ModelRSS

  key :mothered_endpoint_id, ObjectId, :index=>true, :required=>true
  belongs_to :mothered_endpoint

  key :endpoint_path, String, :index=>true
  key :name, String
  key :trace, String

  timestamps!
end