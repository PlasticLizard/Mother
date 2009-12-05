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


  def create_json()
    @ep_hash = { :path => "the/path/to/hell", :name => "my_name_is_mud",:status=>:online }
    @ep_hash.to_json
  end

end