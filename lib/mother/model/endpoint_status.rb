class EndpointStatus < MotherModel
  
  DEFAULTS = {
           :default => {:name=>"Unspecified",:description=>"The status for this endpoint has never been set."},
           :online  => {:name=>"On-Line",:description=>"This endpoint is on-line"},
           :offline => {:name=>"Off-Line",:description=>"This endpoint is off-line"}
  }

  key :name, String, :required => true
  key :description, String

  key :mothered_endpoint_id, ObjectId
  belongs_to :mothered_endpoint

  def self.create(named_status)
    attributes = DEFAULTS[named_status.to_sym]
    raise "#{named_status} is not a valid default status. Please use one of #{DEFAULTS.keys.join(',')}" unless attributes
    EndpointStatus.new(attributes)

  end

  def self.get_default_or_create(status_name)
    status_name = "default" unless status_name
    attributes = DEFAULTS[status_name.to_sym]
    attributes = {:name=>status_name,:description=>status_name} unless attributes
    EndpointStatus.new(attributes)
  end
end