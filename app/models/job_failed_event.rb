class JobFailedEvent < JobEndedEvent
  key :endpoint_error_id, ObjectId

  belongs_to :endpoint_error, :class=>EndpointError
end