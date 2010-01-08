class EndpointsController < ResourceController

   key_field "path"

  def update
    resource.path = params[:id]
    super
  end  
end
