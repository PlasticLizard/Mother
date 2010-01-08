atom_feed do |feed|
  feed.title("Endpoints under Mother's tender care")
  feed.update(@endpoints.first.created_at) if @endpoints.length > 0
  
  @endpoints.each do |ep|
    feed.entry(ep,:url=>globbed_show_url(ep.path)) do |entry|
      entry.title(ep.name ? "#{ep.name} @ #{ep.path}" : ep.path)
      entry.content("Status:#{ep.status}", :type => 'html')
      entry.author { |author| author.name("Mother") }
    end
  end
end