class Location < MotherModel
  key :description, String, :required=>true
  key :address, String
  key :city, String
  key :state, String
  key :zip, String
  key :latitude, Float
  key :longitude, Float
end