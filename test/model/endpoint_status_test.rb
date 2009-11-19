require File.dirname(__FILE__) + "/../test_helper"

class EndpointStatusTest < Test::Unit::TestCase

  context "EndpointStatus::create" do
    should "raise exception when unknown status requested" do
      assert_raise(RuntimeError) do
        EndpointStatus.get_default("unknown")
      end
    end

    should "return EndpointStatus initialized with appropriate attributes" do
      status = EndpointStatus.get_default :online
      assert_equal "On-Line",status.name
    end

    should "work with strings as well as symbols" do
      status = EndpointStatus.get_default("offline")
      assert_equal "Off-Line",status.name
    end
  end
  
end