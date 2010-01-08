require 'test_helper'

class TestResourceController < ResourceController
  key_field "hello_there"
end

class ResourceControllerTest < ActionController::TestCase
  context "ResourceController.finder_method" do
    context "when key_field has been called" do
      should "return find_or_create_by_xxx" do
        assert_equal :find_or_create_by_hello_there, TestResourceController.finder_method
      end
    end
  end

  context "re_glob_id_fields" do

    should "not modify params except :id, :endpoint_path" do
      params = {:ids=>%w(a b c), :endpoints_paths=>%w(e f g)}.with_indifferent_access
      ResourceController.send(:re_glob_id_fields,params)
      assert_equal %w(a b c),params[:ids]
      assert_equal %w(e f g),params[:endpoints_paths]
    end

    should "combine id and endpoint_path with a slash" do
      params = {:id=>%w(a b c), :endpoint_path=>%w(e f g)}.with_indifferent_access
      ResourceController.send(:re_glob_id_fields,params)
      assert_equal "a/b/c", params[:id]
      assert_equal "e/f/g", params[:endpoint_path]
    end

    should "combine id with and then remove final segment" do
      params = {:id=>%w(a b), :final_segment=>"c"}.with_indifferent_access
      ResourceController.send(:re_glob_id_fields,params)
      assert_equal "a/b/c", params[:id]
      assert_nil params[:final_segment]
    end

    should "not combine endpoint_path with final segment" do
      params = {:endpoint_path=>%w(a b), :final_segment=>"c"}.with_indifferent_access
      ResourceController.send(:re_glob_id_fields,params)
      assert_equal "a/b",params[:endpoint_path]
      assert_not_nil params[:final_segment]
    end

    should "not disturb id if it is not an array" do
      params={:id,"a"}.with_indifferent_access
      ResourceController.send(:re_glob_id_fields,params)
      assert_equal "a",params[:id]
    end
    should "not disturb id if it is not an array, even if final_segment is present" do
      params={:id=>"a",:final_segment=>"b"}.with_indifferent_access
      ResourceController.send(:re_glob_id_fields,params)
      assert_equal "a",params[:id]
    end
  end
end
