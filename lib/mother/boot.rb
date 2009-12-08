require File.join(File.dirname(__FILE__),"watchful_eye")

Time.zone = "PST"
WATCHFUL_EYE = WatchfulEye.new(:interval=>0.5) do |eye|
  eye.start
end
