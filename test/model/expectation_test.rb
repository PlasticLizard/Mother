require File.dirname(__FILE__) + "/../test_helper"


class ExpectationTest < Test::Unit::TestCase

  context "Expectation" do
    context "#matches" do
      should "evaluate a true expectation expression against the context if provided" do
        exp = Expectation.new :expectation_expression=>"downcase=='hello'"
        assert_equal true, exp.matches("HeLlo")
      end
      should "evaluate a false expectation expression against the context if provided" do
        exp = Expectation.new :expectation_expression=>"downcase=='hello world'"
        assert_equal false, exp.matches("HeLlo")
      end
      should "return true if no expression is defined" do
        exp = Expectation.new
        assert_equal true, exp.matches("GoOdByE")
      end
    end

    context "#is_expired" do
      should "return false when as_of time is prior to expiration time" do
        exp = Expectation.new(:expiration_time=>Time.parse("01:00 am"))
        assert_equal false, exp.is_expired(Time.parse("12:00 am"))
      end
      should "return true when as_of time is after expiration time" do
        exp = Expectation.new(:expiration_time=>Time.parse("01:00 am"))
        assert exp.is_expired(Time.parse("02:00 am"))
      end
      should "account for a grace period if provided" do
        exp = Expectation.new(:expiration_time=>Time.parse("01:00 am"))
        assert_equal true, exp.is_expired(Time.parse("1:01 am"))
        exp.grace_period = 60
        assert_equal false, exp.is_expired(Time.parse("1:01 am"))
      end
      should "use current time when as_of not provided" do
        exp = Expectation.new(:expiration_time=>Time.now - 1)
        assert_equal true, exp.is_expired
      end
    end

    context "#try_complete" do
      should "set status to expectation_met if expectation is met" do
        exp = Expectation.new
        assert_equal true, exp.try_complete("a context")
        assert_equal :expectation_met, exp.status
      end
      should "leave status unchanged if expectation is not met" do
        exp = Expectation.new :expectation_expression=>"false"
        assert_equal false, exp.try_complete("a context")
        assert_equal :pending, exp.status
      end
    end
    context "#try_expire" do
      should "set status to expectation_unmet if expired" do
        exp = Expectation.new(:expiration_time =>  Time.now - 1)
        assert_equal true,exp.try_expire
        assert_equal :expectation_unmet, exp.status
      end
      should "leave status unchanced if not expired" do
        exp = Expectation.new(:expiration_time=>Time.now + 1)
        assert_equal false,exp.try_expire
        assert_equal :pending, exp.status
      end
    end
  end

  context "EndpointEventExpectation" do
    context "#matches" do
      should "return false if the type of the context does not match the configured type" do
        exp = EndpointEventExpectation.new :expected_event_type_name=>String.name
        assert_equal false, exp.matches(1)
      end
      should "delegate to the base implementation of matches if the context does match the configured type" do
        exp = EndpointEventExpectation.new :expected_event_type_name=>String.name
        assert_equal true, exp.matches("hello there")
      end

    end
  end

  context "JobCompletedExpectation" do
    context "#matches" do
      should "successfully match a JobCompletedEvent with a matching name" do
        exp = JobCompletedExpectation.new :expected_job_name =>"My Job"
        assert exp.matches(JobCompletedEvent.new(:name=>"my job"))
      end
      should "reject a JobCompletedEvent with a mismatched name" do
        exp = JobCompletedExpectation.new :expected_job_name => "My Job"
        assert_equal false, exp.matches(JobCompletedEvent.new(:name=>"your job"))
      end
      should "reject an event with a matching name but of a mismatched type" do
        exp = JobCompletedExpectation.new :expected_job_name => "My Job"
        assert_equal false, exp.matches(EndpointEvent.new(:name=>"My Job"))
      end
    end
  end
end