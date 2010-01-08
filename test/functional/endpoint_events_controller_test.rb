require 'test_helper'

class EndpointEventsControllerTest < ActionController::TestCase
  context "#extract_event_data" do
    setup do
      @c = EndpointEventsController.new
      @params = {:event=>{:a=>:b},:endpoint_event=>{:c=>:d}}
      @json = {:e=>:f}.to_json
      @from_json = JSON.parse(@json)
      @request = {}
    end
    should "return a hash named :event if present" do
      result = @c.send(:extract_event_data,@params,"application/json",nil)
      assert_equal @params[:event], result
    end
    should "return a hash with the name of the resource if present" do
      (params = @params.dup).delete(:event)
      result = @c.send(:extract_event_data,params,"application/json",nil)
      assert_equal @params[:endpoint_event], result
    end
    should "create a hash from the body of the request if event/resource_name don't exist and the content_type is JSON" do
      result = @c.send(:extract_event_data,{},"application/json",@json)
      assert_equal @from_json, result
    end
    should "return an empty hash if event/resource name don't exist and the content type is not JSON" do
      result = @c.send(:extract_event_data,{},"application/gibbrish",@json)
      assert_equal({},result)
    end
  end
  context "Create" do
    setup do
      @ep = Factory(:endpoint)
    end
    context "posted to an existing endpoint" do
      should "load the endpoint and add the event" do
        assert_no_difference('Endpoint.count') do
          assert_difference('EndpointEvent.count',1) do
            post :create, :endpoint_path=>"a/b/c", :name=>"A new event"
            assert_response :success
          end
        end
      end
    end
    context "posted to a non-existant endpoint" do
      should "create the endpoint and add the event" do
        assert_difference('Endpoint.count',1) do
          assert_difference('EndpointEvent.count',1) do
            post :create, :endpoint_path=>"d/e/f", :name=>"A new event"
            assert_response :success
          end
        end
      end
    end
  end

  context "Requesting Index with RSS format" do
    setup do
      Factory.create(:endpoint_event)
      Factory.create(:endpoint_event)
      Factory.create(:endpoint_event)
    end
    should "select an appropriate number of endpoint_events and render a feed" do
      get :index, :format=>"atom", :page=>2, :per_page=>2
      assert_response :ok
      assert assigns["endpoint_events"]
      assert_equal 1, assigns["endpoint_events"].length
      assert_template "index.atom.builder"
    end
  end
end
