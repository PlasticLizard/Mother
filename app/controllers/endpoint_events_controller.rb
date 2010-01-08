class EndpointEventsController < ResourceController

  def create
    ep = endpoint.add_event(EndpointEvent.new(event_data))
    render :text=> ep.id.to_s
  end

  protected

  def endpoint
    @endpoint ||= if request.get?
      Endpoint.find_by_path(params[:endpoint_path])
    else
      Endpoint.find_or_create_by_path(params[:endpoint_path])
    end
  end 

  def event_data
    return @event_data ||= extract_event_data(params,request.content_type,request)
  end

  private
  def extract_event_data(params, content_type, request)
    return  params[:event] || params[resource_instance_name] ||
              (JSON.parse(request) if content_type == "application/json") || {}  
  end
end
