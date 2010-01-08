require "test_helper"

class TownCrierTest  < Test::Unit::TestCase

  context "TownCrier#proclaim" do
    setup do
      @args = {}
      @l1 = Object.new
      @l1.expects(:call).with(:my_event, @args).at_least(2)
      TownCrier.expects(:listeners_for).with(:my_event).returns([@l1,@l1])

    end
    should "invoke #call on all registered listeners" do
      TownCrier.proclaim :my_event, @args
    end
  end

end