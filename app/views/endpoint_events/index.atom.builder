atom_feed do |feed|
  feed.title("Recent Endpoint Events")
  feed.update(@endpoint_events.first.created_at) if @endpoint_events.length > 0

  @endpoint_events.each do |event|
    feed.entry(event,:url=>endpoint_event_url(event.endpoint_path,event.id.to_s)) do |entry|
      entry.title("#{event.name} : #{event.class.name.underscore.humanize} @ #{event.endpoint_path}")
      entry.content(event.respond_to?(:summary) ? event.summary : nil, :type => 'html')
      entry.author { |author| author.name(event.endpoint_path) }       
    end
  end
end