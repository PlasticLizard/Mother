#From http://gist.github.com/262601

config = YAML.load_file(Rails.root + 'config' + 'database.yml')[Rails.env]

MongoMapper.connection = Mongo::Connection.new(config['host'], config['port'], {
        :logger => Rails.logger
})

MongoMapper.database = config['database']
if config['username'].present?
  MongoMapper.database.authenticate(config['username'], config['password'])
end

#I guess I don't really understand what is going on here,
#but I imagine John isn't just spinning the cylinder for
#show here, so I'll try to figure it out later.
Dir[Rails.root + 'app/models/**/*.rb'].each do |model_path|
  model =  File.basename(model_path, '.rb').classify
  model.constantize if Object.const_defined? model
end

MongoMapper.ensure_indexes!

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # if using older than 0.6.5 of MM then you want database instead of connection
    # MongoMapper.database.connect_to_master if forked
    MongoMapper.connection.connect_to_master if forked
  end
end

#This is a hideous way of serializing a MM document into XML
#The strange ~~~ crap is because AR's Hash#to_xml replaces _ with -
#in the XML output - but this is not legal for tag names, so you
#get invalid XML. But I didn't want to replace - in the XML content
#so I did a crazy little bait and switch. This has the drawback that
#any ~~~ that naturally occur in the document will get replaced with
#an underscore. Something better is obviously needed.
module MongoMapper::Document
  def to_xml
    atts = {}
    self.attributes.each do |k,v|
      atts[k.to_s.gsub(/_/,"~~~")] = v
    end
    (atts.to_xml :root=>self.class.name).gsub(/~~~/,"_")
  end
end