require File.join(File.dirname(__FILE__), "../test_helper")

class MotheredEndpointTest < Test::Unit::TestCase

  context "#create_job" do
    setup do
      @jobs, @events = [], []
      @ep = MotheredEndpoint.new :path=>"A Path"
      @ep.expects(:jobs).returns(@jobs)
      @job_start = JobStartedEvent.new :name=>"a new job"
      @job = Job.new :endpoint_path=>"A Path"

    end

    context "when called with a start event" do
      setup  do
        Job.expects(:new).with({:endpoint_path=>"A Path"}).returns(@job)
        @job.expects(:name=).with(@job_start.name)
        Time.expects(:now).returns(Time.parse("12/1/2009")).at_least(1)
        @job.expects(:start_time=).with(Time.parse("12/1/2009"))
        @job.expects(:status=).with(:pending)
        @job.expects(:id).returns("1234")
        @job_start.expects(:job_id=).with("1234")
        @result = @ep.create_job @job_start
      end
      should "create and configure a job, and append the new job to internal collections" do
        assert_equal @job, @jobs[0]
        assert_equal @job,@result
      end
    end

  end

  context "#add_error" do
    setup do
      @ep = MotheredEndpoint.new :path=>"a/b/c"
      @error = EndpointError.new
      @error.expects(:endpoint_path=).with("a/b/c")
      @errors = []
      @ep.expects(:endpoint_errors).returns(@errors)
      TownCrier.expects(:proclaim).with(:endpoint_error,{:error=>@error,:endpoint=>@ep})
    end
    should "set the path on the error, add to the errors collection, and publish the event to the town crier" do
      @ep.add_error(@error)
      assert_equal(@error,@errors[0])
    end
  end

  context "#add_event" do
    setup do
      @ep = MotheredEndpoint.new :path=>"a/b/c"
      @event = JobCompletedEvent.new
      @event.expects(:endpoint_path=).with("a/b/c")
      @events = []
      @ep.expects(:endpoint_events).returns(@events)
      @ep.expects(:complete_expectations).with(@event)
      TownCrier.expects(:proclaim).with(:endpoint_event,{:event=>@event,:endpoint=>@ep})
      @ep.expects(:expect_event).with(@event)

    end
    should "set the path on the error, add to the collection, complete expecations and publish the event to the town crier and setup new expectation" do
      @ep.add_event(@event)
      assert_equal @event, @events[0]
    end
  end

  context "#expect_event" do
    setup do
      @ep = MotheredEndpoint.new :path=>"a/b/c"

    end
    context "when called on a JobCompletedEvent" do
      setup do
        @event = JobCompletedEvent.new :name=>"job",:expect_next_at=>Time.parse("08:00")
        @exp = JobCompletedExpectation.new
        JobCompletedExpectation.expects(:new).returns(@exp)
        @exp.expects(:expected_job_name=).with("job")
        @ep.expects(:expect).with(@exp)
      end
      should "create a JobCompletedExpectation and set the expected job name" do
        @ep.expect_event(@event)
      end
    end
    context "when called on any other type of event" do
      setup do
        @event = EndpointEvent.new :name=>"event",:expect_next_at=>Time.parse("08:00")
        @exp = EndpointEventExpectation.new
        EndpointEventExpectation.expects(:new).returns(@exp)
        @ep.expects(:expect).with(@exp)
      end
      should "create a EndpointEventExpectation" do
        @ep.expect_event(@event)
      end
    end
    context "for all event types" do
      setup do
        @event = EndpointEvent.new :name=>"event",:expect_next_at=>Time.parse("08:00")
        @exp = EndpointEventExpectation.new
        EndpointEventExpectation.expects(:new).returns(@exp)
        @ep.expects(:expect).with(@exp)
      end
      should "set the expiration time" do
        @ep.expect_event(@event)
        assert_equal Time.parse("08:00"),@exp.expiration_time
      end
    end
  end


  def create_json()
    @ep_hash = { :path => "the/path/to/hell", :name => "my_name_is_mud",:status=>:online }
    @ep_hash.to_json
  end

end