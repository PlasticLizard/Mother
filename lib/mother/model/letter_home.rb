class LetterHome < MotherModel
  key :endpoint_id,MongoMapper::ObjectId
  key :endpoint_path, String
  key :message, String
end