require "test_helper"

class RoutesTest < ActionController::TestCase

  context "Endpoints routes" do
    context "that have multi-part paths" do
      setup do
        @path = "endpoints/one/two/three"
        @id = %w(one two three)
      end
      should "route a PUT to update" do
        request = {:path=>@path, :method=>:put}
        route   = {:controller => "endpoints", :action=>"update", :id=>@id}
        assert_routing request, route
      end
      should "route a DELETE to destroy" do
        request = {:path=>@path, :method=>:delete}
        route = {:controller=>"endpoints",:action=>"destroy",:id=>@id}
        assert_routing request, route
      end
      should "route a GET to show" do
        request = {:path=>@path, :method=>:get}
        route = {:controller=>"endpoints",:action=>"show",:id=>%w(one two),:final_segment=>"three"}
        assert_routing request, route
      end
      should "route a GET.format tp show" do
        request = {:path=>@path + ".xml", :method=>:get}
        route = {:controller=>"endpoints",:action=>"show",:id=>%w(one two),:final_segment=>"three",:format=>"xml"}
        assert_routing request, route
      end
    end

    context "that have standard paths" do
      setup do
        @path = "endpoints/one"
      end
      should "route a PUT to update" do
        request = {:path=>@path, :method=>:put}
        route   = {:controller => "endpoints", :action=>"update", :id=>"one"}
        assert_routing request, route
      end
      should "route a POST to create" do
        request = {:path=>"/endpoints",:method=>:post}
        route = {:controller=>"endpoints",:action=>"create"}
        assert_routing request, route
      end
      should "route a DELETE to destroy" do
        request = {:path=>@path, :method=>:delete}
        route = {:controller=>"endpoints",:action=>"destroy", :id=>"one"}
        assert_routing request, route
      end
      should "route a GET to show" do
        request = {:path=>@path, :method=>:get}
        route = {:controller=>"endpoints",:action=>"show",:id=>"one"}
        assert_routing request, route
      end
      should "route a GET with a format to show" do
        request = {:path=>@path + ".xml", :method=>:get}
        route = {:controller=>"endpoints",:action=>"show",:id=>"one",:format=>"xml"}
        assert_routing request, route
      end
    end
  end

  context "Children of Endpoints routes" do
    context "where the endpoint has a multi-part path" do
      should "respect the multi-part path in the prefix" do
        request = {:path=>"endpoints/one/two/three/endpoint_events/four", :method=>"get"}
        route = {:controller=>"endpoint_events", :action=>"show", :endpoint_path=>%w(one two three),:id=>"four"}
        assert_routing request, route
      end
    end
  end

  context "Jobs routes" do
    should "respect the failed addition to the collection route" do
      request = {:path=>"/endpoints/one/two/three/jobs/failed",:method=>:post}
      route = {:controller=>"jobs",:action=>"failed",:endpoint_path=>%w(one two three)}
      assert_routing request,route
    end
    should "respect the completed addition to the collection route" do
      request = {:path=>"/endpoints/one/two/three/jobs/completed",:method=>:post}
      route ={:controller=>"jobs",:action=>"completed",:endpoint_path=>%w(one two three)}
      assert_routing request, route
    end
    should "respected the started addition to the collection route" do
      request = {:path=>"/endpoints/one/two/three/jobs/started",:method=>:post}
      route = {:controller=>"jobs",:action=>"started",:endpoint_path=>%w(one two three)}
      assert_routing request, route
    end
    should "respect the failed addition to the member route" do
      request = {:path=>"/endpoints/one/two/three/jobs/four/failed",:method=>:put}
      route = {:controller=>"jobs", :action=>"failed", :endpoint_path=>%w(one two three), :id=>"four"}
      assert_recognizes route, request
      #assert_generates request[:path],route
    end
    should "respect the completed addition to the member route" do
      request = {:path=>"/endpoints/one/two/three/jobs/four/completed",:method=>:put}
      route = {:controller=>"jobs", :action=>"completed", :endpoint_path=>%w(one two three),:id=>"four"}
      assert_recognizes route, request
      #assert_generates request[:path],route
    end
  end
end


