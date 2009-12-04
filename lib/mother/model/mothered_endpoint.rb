require "json"
require File.dirname(__FILE__) + "/endpoint_status"
require File.dirname(__FILE__) + "/endpoint_event"

class MotheredEndpoint
  include MongoMapper::Document
  
  key :path, String, :required => true, :unique=>true, :index=>true
  key :name, String
  key :status, EndpointStatus

  many :endpoint_events, :polymorphic=>true

  many :jobs do
    def by_status(status)
      all(:status => status)  
    end

  end

  timestamps!

  def create_job(job_start)
    job_start.endpoint_path = self.path
    job = Job.new :endpoint_path=>self.path
    job.name = job_start.name
    job.start_time = job_start.start_time || Time.now
    job.status = :pending
    self.jobs << job
    job_start.job_id = job.id    
    self.endpoint_events << job_start
    job
  end

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