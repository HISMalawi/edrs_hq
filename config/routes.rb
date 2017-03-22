Rails.application.routes.draw do

  get 'reports/index'

  root 'hq#dashboard'

  get "/login" => "users#login"

  post "/login" => "users#login"

  get "/logout" => "users#logout"

  get "/view_users" => "users#view"
  get "/query_users" => "users#query"
  get "/search_user" => "users#search"
  get "/users/new"
  post "/users/create"
  post "/create_user" => "users#create"
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
  get '/settings' => 'users#settings'
  get '/manage_users' => "users#manage_users"
  get 'my_account' => "users#my_account"
  get 'profile/:user_id' => 'users#profile'
  
  ################## cases routes ############################
  get '/open_cases' => 'case#open'
  get '/closed_cases' => 'case#closed'
  get '/hq_incomplete' => 'case#hq_incomplete'
  get '/conflict' => 'case#conflict'
  get '/approve_potential_duplicates' => 'case#approve_potential_duplicates'
  get '/approve_for_reprinting' => 'case#approve_for_reprinting'
  get '/reprinted_certificates' =>"case#reprinted_certificates"
  get '/local_cases' => 'case#local_cases'
  get '/remote_cases' => 'case#remote_cases'
  get '/re_open_cases' => 'case#re_open_cases'
  get '/re_approved_cases' => 'case#re_approved_cases'
  get 'rejected_and_approved_cases' => 'case#rejected_and_approved_cases'
  get '/corrected_from_dc' => "case#corrected_from_dc"

  get '/get_comments' => 'hq#get_comments'
  get '/ajax_save_comment' => 'hq#ajax_save_comment'
  post '/ajax_save_comment' => 'hq#ajax_save_comment'

  get '/approve_for_printing' => 'case#approve_for_printing'
  get '/approve_reprint' => 'case#approve_reprint'
  get '/print' => 'case#print'
  get '/dispatched' => 'case#dispatched'
  get '/re_print' => 'case#re_print'
  get '/dispatch_printouts' => 'case#dispatch_printouts'
  get '/ajax_change_status' => 'case#ajax_change_status'
  post '/ajax_change_status' => 'case#ajax_change_status'

  get '/void_cases' => 'case#void_cases'
  get '/voided_cases' => 'case#voided_cases'
  get '/potential' => 'case#potential'
  get '/can_confirm' => 'case#can_confirm'
  get '/confirmed' => 'case#confirmed'
  get '/view_requests' => 'case#view_requests'
  get '/verify_certificates' => 'case#dispatch_printouts'


  get 'add_more_open_cases/:page_number' => 'case#more_open_cases'
  get '/add_more_open_cases_with_prev_status/:page_number' => "case#more_open_cases_with_prev_status"
  get '/add_more_special_cases/:page_number' => "case#more_special_cases"
  get '/special_cases'=>"case#special_cases"
  get '/approved_incomplete' => "case#approved_for_print_marked_incomplete"
  get 'view_cases/:person_id' => 'case#view_cases'
  get '/incomplete_cases' => 'case#incomplete_cases'
  get '/rejected_cases' => 'case#rejected_cases'

  ############################################################
  get "/search" => "hq#search"
  get "/do_search" => "hq#do_search"
  get "/cause_of_death_preview" => "hq#cause_of_death_preview"
  get "/cause_of_death" => "hq#cause_of_death"
  get "/save_cause_of_death" => "hq#save_cause_of_death"
  get "/cause_of_death_list" => "hq#cause_of_death_list"
  get "/nocause_available/:id" => "hq#nocause_available"

  #printing routes
  
  get '/printed_view/:id' => "hq#printed_view"
  
  get "/print_preview" => "hq#print_preview"
  
  get '/death_certificate_print/:id' => "hq#death_certificate_print"
  
  get '/death_certificate/:id' => "hq#death_certificate"
  
  post 'hq/do_print_these'

  get 'hq/do_print_these'

  get 'hq/death_certificate_preview'

  get '/facilities' => "hq#facilities"

  get '/nationalities' => "hq#nationalities"

  get '/districts' => "hq#districts"

  get "/tas" => "hq#tas"

  get "/villages" => "hq#villages"
  #global property routes

  get "/signature" => "hq#signature"
  
  get "/paper_size" => "hq#paper_size"

  post "/create_property" => "hq#create_property"

  get "/by_reporting_month_and_district" => "hq#by_reporting_month_and_district"
  get "/by_record_status" => "hq#by_record_status"
  get "/manage_duplicates" => "hq#manage_duplicates"

  get '/tasks' => 'hq#tasks'
  get '/rejected_cases_tasks' =>"hq#rejected_cases_tasks"
  get '/special_cases_tasks' => "hq#special_cases_tasks"
  get '/print_out_tasks' => "hq#print_out_tasks"
  get '/duplicate_cases_tasks' =>"hq#duplicate_cases_tasks"
  get '/amendment_cases_tasks' =>"hq#amendment_cases_tasks"
  get '/amendment_requests' =>"case#amendment_requests"
  get '/reprint_requests' => "case#reprint_requests"

  get '/reports' => "reports#index"
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
