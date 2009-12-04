require File.dirname(__FILE__) + "/mothered_endpoint"
require File.dirname(__FILE__) + "/job_events"

class Expectation
  include MongoMapper::Document
  include Mother::ModelRSS

  key :mothered_endpoint_id, ObjectId, :required=>true, :index=>true
  belongs_to :mothered_endpoint

  key :endpoint_path, String, :index=>true

  key :expiration_time, Time, :required=>true
  key :grace_period, Integer

  key :expectation_expression, String

  #should be one of:  pending, expectation_met, expectation_unmet
  key :status, Symbol, :required=>true, :index=>true, :default=>:pending

  timestamps!



  def matches (context)
    if self.expectation_expression
      return context.instance_eval self.expectation_expression
    end
    true
  end

  def is_expired(as_of=Time.now)
    expires_at = (self.expiration_time + (self.grace_period || 0))
    as_of > expires_at
  end

  def try_complete(context = nil)
    if matches context then
      self.status = :expectation_met
      return true
    end
    false
  end

  def try_expire(as_of=Time.now)
    if is_expired(as_of) then
      self.status = :expectation_unmet
      return true
    end
    false
  end

end

class EndpointEventExpectation < Expectation

  key :expected_event_type_name, String

  def matches(context)
    return false unless context.class.name =~ /#{self.expected_event_type_name}/i
    return super(context)
  end

end

class JobCompletedExpectation < EndpointEventExpectation

  key :expected_job_name, String, :required=>true

  def expected_event_type_name
    JobCompletedEvent.name
  end

  def expected_event_type_name=(val)
    raise "expected_event_type_name cannot be set on a JobCompletedEvent"
  end

  def matches(context)
    result = super(context)
    return false unless result &&
            context.respond_to?(:name) &&
            context.name =~ /#{self.expected_job_name}/i
    true
  end

end