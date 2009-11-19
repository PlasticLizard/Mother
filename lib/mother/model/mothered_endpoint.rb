require "json"
require File.dirname(__FILE__) + "/endpoint_status"

class MotheredEndpoint < MotherModel
    
  key :path, String, :required => true, :unique=>true, :index=>true
  key :name, String
  key :status, EndpointStatus

  def save
    ensure_status
    super
  end

  alias :original_status= :status=
  def status=(value)
    if (value.is_a? String or value.is_a? Symbol)
      self.original_status = EndpointStatus.get_or_create_default(value)
    else
      self.original_status = value
    end
  end

  private

  def ensure_status
    new_stat = self.status || EndpointStatus.get_default(:default)
    new_stat.save if (new_stat.new?)
    self.status = new_stat
  end 

end

    
