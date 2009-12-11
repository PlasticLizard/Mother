require File.join(File.dirname(__FILE__),"lib/mother")

Time.zone = "PST"
WATCHFUL_EYE = WatchfulEye.start(:interval=>0.5)

run Mother::Application