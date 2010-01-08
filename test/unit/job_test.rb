require 'test_helper'

class JobTest < Test::Unit::TestCase

 context "Job#complete" do
   setup do
     @job = Job.new :start_time => Time.parse("12/1/2009 08:00")
     @event = JobCompletedEvent.new :end_time => Time.parse("12/1/2009 09:30"), :summary => "I did some important junk"
     @job.complete(@event)
   end
   should "update job data from event" do
     assert_equal @event.end_time,@job.end_time
     assert_equal @event.summary,@job.summary
   end
   should "calculate duration if none provided" do
      assert_equal 90, @job.duration
   end
   should "set the status to completed" do
     assert_equal :completed, @job.status
   end
 end

  context "Job#fail" do
    setup do
     @job = Job.new :start_time => Time.parse("12/1/2009 08:00")
     @event = JobFailedEvent.new :end_time => Time.parse("12/1/2009 09:30"), :endpoint_error_id=>Mongo::ObjectID.new
     @job.fail(@event)
   end
   should "update job data from event" do
     assert_equal @event.end_time, @job.end_time
     assert_equal @event.endpoint_error_id, @job.endpoint_error_id
   end
   should "calculate duration if none provided" do
      assert_equal 90, @job.duration
   end
   should "set the status to completed" do
     assert_equal :failed, @job.status
   end
  end

end