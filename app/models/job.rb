class Job
  include MongoMapper::Document

  key :endpoint_id, ObjectId, :required=>true, :index=>true
  belongs_to :endpoint

  key :endpoint_path, String, :index=>true
  
  key :name, String
  key :summary, String

  key :start_time, Time
  key :end_time, Time
  key :duration, Float

  key :endpoint_error_id, ObjectId
  belongs_to :endpoint_error

  #should be one of: idle, pending, completed, failed
  key :status, Symbol, :required=>true, :index=>true, :default=>:idle

  timestamps!

  def complete(job_complete_event)
    self.summary = job_complete_event.summary if job_complete_event.summary
    self.end_time = job_complete_event.end_time || Time.now
    self.duration = job_complete_event.duration || (self.end_time - self.start_time)/60.0
    self.status = :completed
    TownCrier.proclaim :job_complete, :job=>self
  end

  def fail(job_failed_event)
    self.endpoint_error_id = job_failed_event.endpoint_error_id if job_failed_event.endpoint_error_id
    self.end_time = job_failed_event.end_time || Time.now
    self.duration = job_failed_event.duration || (self.end_time - self.start_time)/60.0
    self.status = :failed
    TownCrier.proclaim :job_failed, :job=>self
  end   

end