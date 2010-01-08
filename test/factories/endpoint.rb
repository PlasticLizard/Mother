Factory.define(:endpoint) do |f|
  #f.sequence(:call_number) {|n| "call_#{n}" }
  f.path "a/b/c"
  f.name "My Endpoint - C"
  f.status :online
end