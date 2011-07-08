CommandAndControl::Application.routes.draw do
  resources :services do
    member do
      get 'exploits'
    end
  end
  
  resources :interfaces do
    member do
      get 'exploits'
    end
  end
  #resources :hosts

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  resources :action_logs do

  end
  resources :knowledge do

  end
  resources :idmef_events do

  end

  resources :console do
    collection do
      post 'input'
      get 'dialog'
    end
  end

  resources :hosts do
    collection do 
      get 'graph'
      get 'svg_graph'
      get 'clear'
      get 'status'
    end
    member do
      get 'nvd_entries'
      get 'info'
      get 'exploits'
      get 'idmef_events'
      get 'idmef_event_groups'
      get 'processes'
    end
  end

  resources :exploits do
    member do
      get 'pick'
    end
  end

  resources :tasks do
    collection do
      post 'scan'
      post 'addroutetosession'
      post 'execreconnaissance'
      post 'installpersistence'
      post 'startbrowserautopwn'
      get 'clean'
    end
    member do
      get 'error'
    end
  end

  resources :prelude_events do

  end

  resources :actions do
    collection do 
      get 'kill_task'
      get 'remove_finished_tasks'
      get 'update_all'
      get 'dialog_closed'
      get 'attack_host'
      get 'attack_interface'
      get 'attack_service'
      get 'reconnaissance'
      post 'scan'
      post 'rate_host'
      get 'next_target'
      get 'next_action'
      get 'clicked_yes'
      get 'clicked_no'
      get 'clean_hosts'
      post 'start_file_autopwn'
      post 'start_browser_autopwn'
      get 'single_exploit_host'
      get 'single_exploit_interface'
      get 'single_exploit_service'
      get 'new_pentest'
      get 'reset_agent'
    end
  end

  resources :events do
    collection do
      get :fetch_next_event
      get :user_response
    end
  end
  
  scope 'welcome' do
    match 'credits' => 'welcome#credits', :via => :get
    match 'license' => 'welcome#license', :via => :get
    match 'documentation' => 'welcome#documentation', :via => :get
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "hosts#graph"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
