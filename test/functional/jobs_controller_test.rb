require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  def setup
    @ep = Factory(:endpoint)
  end
  # Replace this with your real tests.
  context "Posting an event to started" do
    should "should create a new job and add it to the specified endpoint" do
      assert_no_difference('Endpoint.count') do
        assert_difference('EndpointEvent.count',1) do
          assert_difference('Job.count',1) do
            assert_difference('@ep.jobs.count',1) do
              assert_difference('@ep.endpoint_events.count',1) do
                post :started, :endpoint_path=>@ep.path,:job=>{:start_time=>Time.parse("01/01/2010")}
                assert_response :success
                assert_equal @ep.jobs[0].id, @ep.endpoint_events[0].job_id
              end
            end
          end
        end
      end
    end
  end

  context "POSTing an event to completed" do
    should "create and complete a job" do
      assert_no_difference('Endpoint.count') do
        assert_difference('Job.count') do
          post :completed, :endpoint_path=>@ep.path, :job=>{:end_time=>Time.parse("1/1/2001")}
          assert_response :success
          assert_equal Job.last(:order=>"created_at").status, :completed
        end
      end
    end
  end

  context "PUTting an event to completed" do
    context "with an existing job_id" do
      setup do
        @job = @ep.create_job(JobStartedEvent.new({:name=>"a job"}))
      end
      should "load the job and close it" do
        assert_no_difference('Job.count') do
          assert_difference('EndpointEvent.count',1) do
            put :completed, :endpoint_path=>@ep.path, :id=>@job.id,:job=>{:end_time=>Time.parse("1/1/2001")}
            assert_response :success
            assert_equal :completed,@job.reload.status
          end
        end
      end
    end
    context "with a non-existent job_id" do
      should "return a 404 (Not Found)" do
        assert_no_difference('Job.count') do
          put :completed, :endpoint_path=>@ep.path,:id=>Mongo::ObjectID.new,:job=>{:end_time=>Time.parse("1/1/2001")}
          assert_response :not_found
        end
      end
    end
  end

  context "POSTing an event to failed" do
    should "create and fail a job" do
      assert_no_difference('Endpoint.count') do
        assert_difference('Job.count') do
          post :failed, :endpoint_path=>@ep.path, :job=>{:end_time=>Time.parse("1/1/2001")}
          assert_response :success
          assert_equal Job.last(:order=>"created_at").status, :failed
        end
      end
    end
  end

  context "PUTting an event to failed" do
    context "with an existing job_id" do
      setup do
        @job = @ep.create_job(JobStartedEvent.new({:name=>"a job"}))
      end
      should "load the job and fail it" do
        assert_no_difference('Job.count') do
          assert_difference('EndpointEvent.count',1) do
            put :failed, :endpoint_path=>@ep.path, :id=>@job.id,:job=>{:end_time=>Time.parse("1/1/2001")}
            assert_response :success
            assert_equal :failed,@job.reload.status
          end
        end
      end
    end
    context "with a non-existent job_id" do
      should "return a 404 (Not Found)" do
        assert_no_difference('Job.count') do
          put :failed, :endpoint_path=>@ep.path,:id=>Mongo::ObjectID.new,:job=>{:end_time=>Time.parse("1/1/2001")}
          assert_response :not_found
        end
      end
    end
  end

  context "Requesting Index with RSS format" do
    setup do
      Factory.create(:job)
      Factory.create(:job)
      Factory.create(:job)
    end
    should "select an appropriate number of jobs and render a feed" do
      get :index, :format=>"atom", :page=>2, :per_page=>2
      assert_response :ok
      assert assigns["jobs"]
      assert_equal 1, assigns["jobs"].length
      assert_template "index.atom.builder"
    end
  end
end
