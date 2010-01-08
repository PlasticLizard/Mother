ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.all_endpoint_events '/endpoint_events.:format',
                           :controller=>"endpoint_events",:action=>"index", :conditions => { :method=>:get }

  map.all_jobs '/jobs.:format',:controller=>"jobs",:action=>"index", :conditions=>{:method=>:get}

  map.with_options :path_prefix=>'/endpoints/*endpoint_path' do |ep|
    ep.resources :endpoint_events, :endpoint_errors, :endpoint_expectations
    ep.resources :jobs,
                  :collection=> {:failed=>:post, :completed=>:post, :started=>:post},
                  :member=>{:failed=>:put, :completed=>:put}
  end


  map.resources :endpoints

  #The final segment hack is there because, from what I can tell
  #parameter globing doesn't work with a dot, i.e. *id.:format,
  #so there is is rather unfortunate need to split out the last
  #path segment to match the format.
  map.with_options :controller=>'endpoints',:action=>'show', :conditions=>{:method=>:get} do |ep|
    ep.globbed_show_with_format 'endpoints/*id/:final_segment.:format'
    ep.globbed_show 'endpoints/*id'
  end


  map.globbed_update 'endpoints/*id', :action=>'update', :conditions=>{:method=>:put}, :controller=>"endpoints"
  map.globbed_delete 'endpoints/*id', :action=>'destroy', :conditions=>{:method=>:delete}, :controller=>"endpoints"
 
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
