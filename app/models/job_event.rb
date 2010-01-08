class JobEvent < EndpointEvent
  key :job_id, ObjectId, :index=>true
  belongs_to :job
end