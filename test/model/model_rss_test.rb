require File.dirname(__FILE__) + "/../test_helper"

class MyModel
  extend Mother::ModelRSS
end

class ModelRSSTest < Test::Unit::TestCase
  context "Calling to_rss on a model that has included the ModelRSS module" do
    context "when included on a model with no documents" do
      setup do
        MyModel.expects(:find).returns([])
        @xml = MyModel.to_rss
      end

      should "produce default RSS XML" do
        assert /<title>My Model<\/title>/ =~ @xml
        assert /<link>#nolink<\/link>/ =~ @xml
        assert /<description>List of recent My Models<\/description>/ =~ @xml
      end

    end

    context "when included on a model with a document" do
      setup do
        @doc = MyModel.new
        MyModel.expects(:find).with(:all, {:limit => 25, :order => '$natural -1'}).returns([@doc])
        @doc.expects(:name).returns("My Title")
        @doc.expects(:erb_value).returns("ERB!")
        @doc.expects(:updated_at).at_least(1).returns("08/04/1976 08:00")
        @doc.expects(:description).returns("A Description 4 U")
        @xml = MyModel.to_rss :item_link_template => "Template courtesy of <%=model.erb_value%>"
      end
      should "include an appropriately formatted RSS item" do
        assert /<title>My Title<\/title>/ =~ @xml
        assert /<link>Template courtesy of ERB!<\/link>/ =~ @xml
        assert /<description>A Description 4 U<\/description>/ =~ @xml
        assert /<pubDate>.*04 Aug 1976.*<\/pubDate>/ =~ @xml
      end
    end
  end
end
