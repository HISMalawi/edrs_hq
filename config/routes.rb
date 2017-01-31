Rails.application.routes.draw do

  root 'hq#dashboard'

  get "/login" => "users#login"

  post "/login" => "users#login"

  get "/logout" => "users#logout"

  get "/view_users" => "users#view"
  get "/query_users" => "users#query"
  get "/search_user" => "users#search"
  get "/users/new"
  post "/users/create"
  get "/search_user" => "users#search"
  get "/search_by_username/:id" => "users#search_by_username"
  get "/search_by_username" => "users#search_by_username"
  get "/username_availability" => "users#username_availability"
  get "/block_user/:id" => "users#block_user"
  get "/unblock_user/:id" => "users#unblock_user"
  get "/block" => "users#block"
  get "/unblock" => "users#unblock"
  get "/users/edit"
  patch "/users/edit"

  ################## cases routes ############################
  get '/open_cases' => 'case#open'
  get '/closed_cases' => 'case#closed'
  get '/dm_reject' => 'case#dm_reject'
  get '/conflict' => 'case#conflict'
  get '/approve_potential_duplicates' => 'case#approve_potential_duplicates'
  get '/approve_for_reprinting' => 'case#approve_for_reprinting'
  get '/local_cases' => 'case#local_cases'
  get '/remote_cases' => 'case#remote_cases'
  get '/re_open_cases' => 'case#re_open_cases'

  get '/approve_for_printing' => 'case#approve_for_printing'
  get '/approve_reprint' => 'case#approve_reprint'
  get '/print' => 'case#print'
  get '/dispatched' => 'case#dispatched'
  get '/re_print' => 'case#re_print'
  get '/dispatch_printouts' => 'case#dispatch_printouts'
  get '/ajax_change_status' => 'case#ajax_change_status'
  post '/ajax_change_status' => 'case#ajax_change_status'


  get 'add_more_open_cases/:page_number' => 'case#more_open_cases'
  get 'view_cases/:person_id' => 'case#view_cases'
  get '/incomplete_cases' => 'case#incomplete_cases'
  get '/rejected_cases' => 'case#rejected_cases'

  ############################################################
  get "/search" => "hq#search"
  
  #printing routes
  
  get '/printed_view/:id' => "hq#printed_view"
  
  get "/print_preview" => "hq#print_preview"
  
  get '/death_certificate_print/:id' => "hq#death_certificate_print"
  
  post 'hq/do_print_these'

  get 'hq/do_print_these'

  get 'hq/death_certificate_preview'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
