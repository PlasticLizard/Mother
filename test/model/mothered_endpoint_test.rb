require File.join(File.dirname(__FILE__), "../test_helper")

class MotheredEndpointTest < Test::Unit::TestCase

  context "#status=" do
    setup { @ep = MotheredEndpoint.new }

    context "when assigned a string matching a default status" do
      should "replace the string with the default EndpointStatus" do
        @ep.status = "online"
        assert_equal EndpointStatus::DEFAULTS[:online][:name], @ep.status.name
      end
    end

    context "when assigned a string that does not match a default status" do
      should "create a new status using the provided status name" do
        @ep.status = "unknown_status"
        assert_equal "unknown_status", @ep.status.name
        assert_equal "unknown_status", @ep.status.description
      end
    end

    context "when assigned a hash" do
      should "should delegate the call to the previous implementation" do
        hash = {:name=>"whatever",:description=>"whatever"}
        @ep.expects(:original_status=).with(hash)
        @ep.status = hash
      end
    end

  end

  context "A MotheredEndpoint given a JSON string with a status hash" do
    setup do
      @ep = MotheredEndpoint.new
      @ep.from_json(create_json(true))
    end

    should "apply the provided fields" do
      assert_equal @ep.name, @ep_hash[:name]
      assert_equal @ep.path, @ep_hash[:path]
      assert_not_nil @ep.status
      assert_equal @ep.status.name, @ep_hash[:status][:name]
      assert_equal @ep.status.description, @ep_hash[:status][:description]      
    end
  end

  context "#ensure_status" do
    context "when called on an endpoint with no previous status" do
      setup do
        defaults = EndpointStatus::DEFAULTS[:default]
        new_status = EndpointStatus.new defaults
        EndpointStatus.expects(:new).at_least(2).returns(new_status)
        new_status.expects(:save).returns(true)
        @ep = MotheredEndpoint.new
        @ep.send(:ensure_status)
      end
      should "set and save the default status" do
        assert_not_nil @ep.status
        assert_equal EndpointStatus::DEFAULTS[:default][:name], @ep.status.name
        assert_equal EndpointStatus::DEFAULTS[:default][:description], @ep.status.description
      end
    end

    context "when called on an endpoint with a previous status" do
      setup do
        @new_status = EndpointStatus.get_default :online

        @ep = MotheredEndpoint.new
        @ep.status = @new_status
        @ep.send(:ensure_status)
      end
      should "not overwrite existing status" do
        assert_not_equal EndpointStatus::DEFAULTS[:default][:name], @ep.status.name
        assert_equal @new_status.name, @ep.status.name
      end
    end
  end

  def create_json(include_status = false)
    @ep_hash = { :path => "the/path/to/hell", :name => "my_name_is_mud" }
    @ep_hash[:status] =  { :name=>"on-line",:description=>"ye be on-line scurvy dog" } if include_status
    @ep_hash.to_json
  end

end