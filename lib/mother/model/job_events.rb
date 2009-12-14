class JobEvent < EndpointEvent
  key :job_id, ObjectId, :index=>true
  belongs_to :job
end

class JobStartedEvent < JobEvent
  key :start_time, Time
end

class JobEndedEvent < JobEvent
  key :duration, Float
  key :end_time, Time
end

class JobCompletedEvent < JobEndedEvent
  key :summary, String
end

class JobFailedEvent < JobEndedEvent
  key :endpoint_error_id, ObjectId

  belongs_to :endpoint_error, :class=>EndpointError
end