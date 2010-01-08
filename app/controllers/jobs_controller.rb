class JobsController < EndpointEventsController

  def started
    event = JobStartedEvent.new(self.event_data)
    job = endpoint.create_job(event)
    render_result job
  end

  def completed
    job = close_job(:completed)
    render_result job
  end

  def failed
    job = close_job(:failed)
    render_result job
  end

  private

  def render_result(job)
    job ? render(:text=>job.id.to_s) : head(:not_found)
  end

  def close_job(event_type)
    event = "job_#{event_type}_event".classify.constantize.new(event_data)
    job = get_job(:name=>event.name)
    return nil unless job
    job.send(event_type==:completed ? "complete" : "fail",event)
    job.save
    event.job_id = job.id
    endpoint.add_event(event)
    job
  end

  def get_job(job_data={})
    @job ||= if params[:id]
      #This should redirect to a 404 if nothing came back from the search
      Job.find(params[:id])
    else
      started_event = JobStartedEvent.new(job_data)
      endpoint.create_job(started_event)
    end
  end

end
