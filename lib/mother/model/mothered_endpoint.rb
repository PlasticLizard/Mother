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

  many :endpoint_errors

  timestamps!

  after_validation "notify_if_status_changed"
  def notify_if_status_changed
    if (self.status_changed?)
      TownCrier.proclaim :endpoint_status_changed,:previous_status=>self.changes["status"][0],:new_status=>self.status,:endpoint=>self
    end
  end

  def create_job(job_start)
    job = Job.new :endpoint_path=>self.path
    job.name = job_start.name
    job.start_time = job_start.start_time || Time.now
    job.status = :pending
    self.jobs << job
    job_start.job_id = job.id
    job
  end

  def add_error(error)
    error.endpoint_path = self.path
    self.endpoint_errors << error
    TownCrier.proclaim(:endpoint_error, :error=>error, :endpoint=>self)
  end

  def add_event(event)
    event.endpoint_path = self.path
    self.endpoint_events << event
    complete_expectations(event)
    TownCrier.proclaim(:endpoint_event, :event=>event, :endpoint=>self)
    expect_event(event) if event.respond_to?(:expect_next_at)
  end

  def expect_event(event)
    return unless event.expect_next_at
    if event.is_a? JobCompletedEvent
      expectation = JobCompletedExpectation.new
      expectation.expected_job_name = event.name if event.is_a?(JobEvent)
    else
      expectation = EndpointEventExpectation.new
    end
    expectation.expiration_time = event.expect_next_at
    expect(expectation)
  end

  def expect(expectation)
    expectation.endpoint_path = self.path
    self.expectations << expectation
  end

  private
  def complete_expectations(event)
    self.expectations.all(:status=>pending).each do |expectation|
      expectation.save if expectation.try_complete(event)
    end
  end

end