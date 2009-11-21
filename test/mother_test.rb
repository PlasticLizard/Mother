require "test_helper"
require "mocha"

class MotherTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @path = "my_operational_unit/my_server/my_endpoint"
    @new_ep = MotheredEndpoint.new
  end

  context "Mother, when a client PUTs a JSON endpoint definition"  do
    setup do
      @new_ep_json = {
              :path=>@path,
              :name=>"My Endpoint",
              :status => { :name => "On-line", :description => "On-line and ready to go"}
      }.to_json
      @new_ep.expects(:from_json).with(@new_ep_json)
      @new_ep.expects(:save).returns(true)
    end

    context "that already exists," do
      setup do
        MotheredEndpoint.expects(:find_by_path).with(@path).returns(@new_ep)
        put '/endpoint/' + @path, @new_ep_json
      end
      should "update the existing endpoint and return its path" do
        assert last_response.ok?
        assert_equal @path, last_response.body
      end
    end

    context "that does not exist," do
      setup do
        MotheredEndpoint.expects(:find_by_path).with(@path).returns(nil)
        MotheredEndpoint.expects(:new).returns(@new_ep)
        put '/endpoint/' + @path, @new_ep_json
      end

      should "create a new endpoint and return its path" do
        assert last_response.ok?
        assert_equal @path, last_response.body
      end
    end

  end

  context "Mother, when a client PUTs a status" do
    context "in JSON format" do
      setup do
        @status_json = { :status => "offline"}.to_json
      end

      context "to an existing endpoint," do
        setup do
          @ep_status = EndpointStatus.new
          MotheredEndpoint.expects(:find_by_path).with(@path).returns(@new_ep)
          @new_ep.expects(:status=).with(JSON.parse(@status_json))
          @new_ep.expects(:save).returns(true)
          put '/endpoint/' + @path + '/status',@status_json
        end

        should "update the status for that endpoint" do
          assert last_response.ok?
          assert_equal "", last_response.body
        end
      end
    end

    context "to a non-existing endpoint," do
      setup do
        MotheredEndpoint.expects(:find_by_path).with(@path).returns(nil)
        put '/endpoint/' + @path + '/status', "{x:y}"
      end

      should "return a 404 error code" do
        assert_equal last_response.status, 404
      end
    end

    context "as a simple string" do
      setup do
        @ep_status = EndpointStatus.new
        MotheredEndpoint.expects(:find_by_path).with(@path).returns(@new_ep)
        @new_ep.expects(:status=).with("online")
        @new_ep.expects(:save).returns(true)
        put '/endpoint/' + @path + '/status',"online"
      end
      should "not attempt to parse as JSON" do
        assert last_response.ok?
      end
    end

  end

  context "Mother, when a client GETs /endpoint/all/events.rss and no parameters" do
    setup do
      EndpointEvent.expects(:to_rss).with({}).returns("<rss/>")
      get '/endpoint/all/events.rss'
    end
    should "request an RSS feed with default options" do
      assert last_response.ok?
      assert_equal last_response.body, "<rss/>"
    end
  end

  context "Mother, when a client GETs /endpoint/all/events.rss and a max_results parameter" do
    setup do
      EndpointEvent.expects(:to_rss).with({:max_results=>1}).returns("<rss/>")
      get '/endpoint/all/events.rss?max_results=1'
    end
    should "request an RSS feed using max_results in the options" do
      assert last_response.ok?
      assert_equal last_response.body, "<rss/>"
    end
  end


  context "Mother, when a client POSTs an event" do
    setup do
      @event_data = {
              :event_type => 'system management/jobs/job started',
              :job_name => 'shave queued monkeys',
              :queue_count => 134,
              :endpoint_path => @path
      }
      @event = EndpointEvent.new
      @event.attributes = @event_data
      @events = {}
      @new_ep.expects(:endpoint_events).returns(@events)
      @events.expects(:build).with(JSON.parse(@event_data.to_json)).returns(@event)
      @event.expects(:save).returns(true)
    end
    context "to an existing endpoint the event" do

      setup do
        MotheredEndpoint.expects(:find_by_path).with(@path).returns(@new_ep)
        post 'endpoint/' + @path + '/event', @event_data.to_json
      end

      should "be appended to the endpoints event history" do
        assert last_response.ok?
      end

    end

    context "to a non-existent endpoint" do

      setup do
        MotheredEndpoint.expects(:find_by_path).with(@path).returns(nil)
        MotheredEndpoint.expects(:create).with(:path=>@path).returns(@new_ep)
        post 'endpoint/' + @path + '/event', @event_data.to_json
      end

      should "create a placeholder for the endpoint using the path and append the event" do
        assert last_response.ok?
      end
    end
  end

  def app
    Mother::Application
  end

end


