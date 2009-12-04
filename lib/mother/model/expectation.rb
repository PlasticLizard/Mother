require File.dirname(__FILE__) + "/mothered_endpoint"

class Expectation
  include MongoMapper::Document
  include Mother::ModelRSS

  key :mothered_endpoint_id, ObjectId, :required=>true, :index=>true
  belongs_to :mothered_endpoint

  key :endpointPath, String, :index=>true

  key :expiration_time, Time, :required=>true
  key :grace_period, Integer

  key :expectation_expression, String

    #should be one of:  pending, expectation_met, expectation_unmet
  key :status, Symbol, :required=>true, :index=>true

  timestamps!

  def matches (context)
    if self.expectation_expression
      return context.instance_eval self.expectation_expression
    else
      return true
    end
  end

  def is_expired()
    expires_at = (self.expiration_time + (self.grace_period || 0))
    Time.now > expires_at
  end

  def try_complete(context)
    self.status = :expectation_met if matches context
    self.status != :pending
  end

  def try_expire()
    self.status = :expectation_unmet if is_expired
    self.status != :pending
  end
  
end

class EndpointEventExpectation < Expectation

  key :expected_event_type_name, String

  def matches(context)
    return false unless context.class.name =~ /#{self.expected_event_type_name}/i
    return super(context)
  end

end

class JobCompleteExpectation < EndpointEventExpectation

  key :expected_job_name, String, :required=>true

  def initialize
    self.expected_event_type_name = "JobCompletedEvent"
    self.expectation_expression = "name == #{self.expected_job_name}"
  end


end