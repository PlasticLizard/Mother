require 'test_helper'

class EndpointsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  context "Updating an endpoint" do
    setup do
      Factory(:endpoint)
    end
    should "set the path from the URL onto the model" do
      assert_difference('Endpoint.count',1) do
        put :update, :id=>"c/d/e", :endpoint=>{:name=>"an endpoint"}
        assert_response :success
        assert_not_nil Endpoint.find_by_path("c/d/e")
      end
    end
  end

  context "Requesting Index with RSS format" do
    setup do
      Factory.create(:endpoint,:path=>"a/b/1")
      Factory.create(:endpoint,:path=>"a/b/2")
      Factory.create(:endpoint,:path=>"a/b/3")
    end
    should "select an appropriate number of endpoints and render a feed" do
      get :index, :format=>"atom", :page=>2, :per_page=>2
      assert_response :ok
      assert assigns["endpoints"]
      assert_equal 1, assigns["endpoints"].length
      assert_template "index.atom.builder"
    end
  end
end
