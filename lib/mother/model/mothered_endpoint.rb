require "json"

class MotheredEndpoint < MotherModel
    
  key :path, String, :required => true, :unique=>true
  key :name, String
  key :status, EndpointStatus

  def save
    super
    ensure_status
  end

  alias :original_status= :status=
  def status=(value)
    if (value.is_a? String or value.is_a? Symbol)
      self.original_status = EndpointStatus.get_default_or_create(value)
    else
      self.original_status = value
    end
  end

  private

  def ensure_status
    self.status = EndpointStatus.create(:default) if self.status.nil?
    self.status.save
  end 

end

    
