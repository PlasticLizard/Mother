class ResourceController < InheritedResources::Base
  before_filter :prepare_params
  
   respond_to :xml, :json, :html
   respond_to :atom, :only => :index

  class << self

    def key_field(field_name)
      @key_field = field_name
    end

    #The name of the field to be
    #used to fetch the requested resource
    def finder_method(find_only = false)
      upsert = find_only ? "" : "_or_create"
      (@key_field ? "find#{upsert}_by_#{@key_field}" : "find#{upsert}_by_id").to_sym
    end
  end

  alias :repository :end_of_association_chain

  #Controllers inheriting from message_controller.rb
  #will generally be updated via code, so
  #a redirect (the default) is pointless, as is
  #returning an xml or json version of the resource.
  #Therefore, we'll just send back a thumbs up.
  def update
    update! do |format|
      format.all { head :ok }
    end
  end

  protected

  def collection
    criteria = {:page=>params[:page], :per_page=>(params[:per_page] || 50),:order=>"updated_at desc"}
    criteria[:endpoint_path]=params[:endpoint_path] if params[:endpoint_path]
    get_collection_ivar ||
             set_collection_ivar(repository.paginate(criteria))
  end
  
  #Fetches the resource for upsert
  def resource
     get_resource_ivar ||
             set_resource_ivar(repository.send(self.class.finder_method(request.get?),params[:id]))
  end

  #a clumsy attempt to reproduce Sinatra's params[:splat]
  #method of parameter globing
  def prepare_params
    self.class.re_glob_id_fields params
  end

  def self.re_glob_id_fields(params)
    ["id","endpoint_path"].each do |key|
      next unless (p = params[key]) && params[key].is_a?(Array)
      p << [params.delete(:final_segment)] if key == "id" and not params[:final_segment].blank?
      params[key] = p.join('/')
    end
  end
end
