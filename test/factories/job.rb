Factory.define(:job) do |f|
  f.sequence(:endpoint_path) {|n| "a/b/#{n}" }
  f.sequence(:name) {|n| "Event #{n}"}
  f.endpoint_id Mongo::ObjectID.new
end