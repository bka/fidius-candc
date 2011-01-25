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
  map.resources :hosts, :collection => {
    :graph => :get,
    :svg_graph => :get,
    :clear => :get
  },:member => {
    :info => :get,
    :nvd_entries => :get
  }
    
  map.resources :terminals, :collection => {:send_cmd => :post}, :member=>{:meterpreter=>:get}

  map.resources :tasks, :collection => {
    :scan => :post,
    :addroutetosession => :post,
    :arpscannsession => :post,
    :execreconnaissance => :post,
    :installpersistence => :post,
    :startbrowserautopwn => :post,
    :clean => :get
  }
  map.resources :payload_logs
  map.resources :prelude_logs
  map.resources :workers, :collection => {
    :start => :post,
    :restart => :put,
    :stop => :delete
  }
  map.credits '/credits', :controller => :welcome, :action => :credits
  map.browser_autopwn '/browser_autopwn', :controller => :welcome, :action => :browser_autopwn
  map.license '/license', :controller => :welcome, :action => :license
    
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
  map.root :controller => :hosts

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
