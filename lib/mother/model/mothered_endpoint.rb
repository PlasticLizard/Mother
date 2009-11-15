class MotheredEndpoint < MotherModel
  
  key :path, String, :required => true
  key :name, String
  key :status, String
  key :status_updated, Time
    
end