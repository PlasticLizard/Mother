class LetterHome
  include MongoMapper::Document

  key :endpoint_path, String, :unique=>true, :index=>true
  key :message, String

  timestamps!
end