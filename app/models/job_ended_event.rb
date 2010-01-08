class JobEndedEvent < JobEvent
  key :duration, Float
  key :end_time, Time
end