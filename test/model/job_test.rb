require File.dirname(__FILE__) + "/../test_helper"

class JobTest < Test::Unit::TestCase

 context "Job#complete" do
   should "not fail" do
     job = Job.new
     job.complete(job)
   end
 end

  context "Job#fail" do
    should "not fail" do
      job = Job.new
      job.fail(job)
    end
  end

end