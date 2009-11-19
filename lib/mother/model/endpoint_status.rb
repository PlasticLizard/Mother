class EndpointStatus
  include MongoMapper::EmbeddedDocument
  
  DEFAULTS = {
           :default => {:name=>"Unspecified",:description=>"The status for this endpoint has never been set."},
           :online  => {:name=>"On-Line",:description=>"This endpoint is on-line"},
           :offline => {:name=>"Off-Line",:description=>"This endpoint is off-line"}
  }

  key :name, String, :required => true
  key :description, String

  def self.get_default(status)
    attributes = DEFAULTS[status.to_sym]
    raise "#{status} is not a valid default status. Please use one of #{DEFAULTS.keys.join(',')}" unless attributes
    EndpointStatus.new(attributes)
  end  

  def self.get_or_create_default (status_name)
    status_name = "default" unless status_name
    attributes = DEFAULTS[status_name.to_sym]
    attributes = {:name=>status_name,:description=>status_name} unless attributes
    EndpointStatus.new(attributes)
  end
end