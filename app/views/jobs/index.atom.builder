atom_feed do |feed|
  feed.title("Recent Jobs")
  feed.update(@jobs.first.created_at) if @jobs.length > 0
  
  @jobs.each do |job|
    feed.entry(job, :url=>job_url(job.endpoint_path,job.id.to_s)) do |entry|
      entry.title(job.name)
      entry.content("#{job.status}<br/><i>#{job.summary}</i>", :type => 'html')
      entry.author { |author| author.name(job.endpoint_path) }
    end
  end
end