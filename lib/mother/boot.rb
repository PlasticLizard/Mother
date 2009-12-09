require File.join(File.dirname(__FILE__),"watchful_eye")

Time.zone = "PST"
WATCHFUL_EYE = WatchfulEye.start(:interval=>0.5)
