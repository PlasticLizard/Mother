class Service
  include MongoMapper::Document

  key :id, String, :required => true
  key :name, String
end