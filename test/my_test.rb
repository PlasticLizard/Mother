require "rubygems"
require "test/unit"
require "shoulda"


class MyTest < Test::Unit::TestCase

  context "A prostitute" do
    setup do
      @x = 5
    end

    should "pleasure me" do
      assert_equal 5,@x
    end

    should "not yell at me" do
      assert_equal true,true
    end

    should "not spit on me or the floor" do
      assert_equal true,true
    end
  end

  context "When mensturating"  do
    should "stay away" do
       puts "howdy"
    end

    should "use a tampon" do

    end
    
  end
end


  