require File.dirname(__FILE__) + "/endpoint_event"
require File.dirname(__FILE__) + "/endpoint_error"

class JobEvent < EndpointEvent
  key :job, String, :required=>true
end

class JobStartedEvent < JobEvent; end

class JobEndedEvent < JobEvent
  key :duration_in_seconds, Float
end

class JobCompletedEvent < JobEndedEvent
  key :summary, String
end

class JobFailedEvent < JobEndedEvent
  key :endpoint_error_id, ObjectId

  belongs_to :endpoint_error, :class=>EndpointError
end