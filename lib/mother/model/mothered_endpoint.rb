require "json"
require File.dirname(__FILE__) + "/endpoint_event"

class MotheredEndpoint
  include MongoMapper::Document

  key :path, String, :required => true, :unique=>true, :index=>true
  key :name, String
  key :status, Symbol, :index=>true, :default=>:unknown

  many :endpoint_events, :polymorphic=>true

  many :jobs

  many :expectations, :polymorphic=>true

  timestamps!

  def create_job(job_start)
    job = Job.new :endpoint_path=>self.path
    job.name = job_start.name
    job.start_time = job_start.start_time || Time.now
    job.status = :pending
    self.jobs << job
    job_start.job_id = job.id    
    job
  end

  def add_event(event)
    event.endpoint_path = self.path
    self.endpoint_events << event
    self.expectations.all(:status=>:pending).each do |expectation|
      expectation.save if expectation.try_complete(event)
    end
  end

  def status=(value)
   @status = value.to_sym if value
  end

  def expect(expectation)
    expectation.endpoint_path = self.path
    self.expectations << expectation
  end

end