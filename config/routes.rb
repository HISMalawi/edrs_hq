Rails.application.routes.draw do

  get 'reports/index'

  root 'hq#dashboard'
  get  'dashbord_data'=>"hq#dashbord_data"

  ################## users routes starts ############################
  get '/build_mysql_database' => 'users#build_mysql_database'
  get 'create_mysql_database/:page_number/:records_per_page/:model_name/:table_name/:table_primary_key' => 'users#create_mysql_database'
  post '/database_load' => 'users#database_load'
  get 'database_load_progress/:table_name' => 'users#database_load_progress'
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
  get "/users/clear_all_locks"

  get "/confirm_username" => "users#confirm_username"
  post "/confirm_username" => "users#confirm_username"

  get "/users/block_user/:id" => "users#block_user"
  
  get "/block" => "users#block"
  get "/users/unblock_user/:id" => "users#unblock_user"
  get "/users/edit_account" => "users#edit_account"
  patch "/users/edit"
  post "/confirm_password" => "users#confirm_password"
  get "/confirm_password" => "users#confirm_password"
  get "/update_password" => "users#update_password"
  post "/update_password" => "users#update_password"
  post "/update_demographics" => "users#update_demographics"
  get "/users/change_password" => "users#change_password" 
  get "users/show/:id" => "users#show" 
  get '/settings' => 'users#settings'
  get '/manage_users' => "users#manage_users"
  get 'my_account' => "users#my_account"
  post 'my_account' => "users#my_account"
  get 'profile/:user_id' => 'users#profile'
  ################## users routes ends ############################
  
  ################## cases routes ############################
  get '/open_cases' => 'case#open'
  get '/closed_cases' => 'case#closed'
  get '/hq_incomplete' => 'case#hq_incomplete'
  get '/conflict' => 'case#conflict'
  get '/approve_potential_duplicates' => 'case#approve_potential_duplicates'
  get '/approved_duplicate' =>"case#approved_duplicate"
  get '/approve_for_reprinting' => 'case#approve_for_reprinting'
  get '/reprinted_certificates' =>"case#reprinted_certificates"
  get '/local_cases' => 'case#local_cases'
  get '/remote_cases' => 'case#remote_cases'
  get '/re_open_cases' => 'case#re_open_cases'
  get '/re_approved_cases' => 'case#re_approved_cases'
  get 'rejected_and_approved_cases' => 'case#rejected_and_approved_cases'
  get '/edited_from_dc' => "case#edited_from_dc"
  get "/case/find/:id" => "case#find"
  get "/case/unlock_record"

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
  get "/save_barcode/:id" => "case#save_barcode"
  post "/save_barcode/:id" => "case#save_barcode"

  get '/void_cases' => 'case#void_cases'
  get '/voided_cases' => 'case#voided_cases'
  get '/potential' => 'case#potential'
  get "/resolve_duplicates" => "case#resolve_duplicates"
  get '/can_confirm' => 'case#can_confirm'
  get '/confirmed' => 'case#confirmed'
  get '/rejected_requests' => 'case#rejected_requests'
  get '/verify_certificates' => 'case#verify_certificates'
  get '/printed_amended_or_reprint' => "case#printed_amended_or_reprint"


  get 'add_more_open_cases/:page_number' => 'case#more_open_cases'
  get '/add_more_open_cases_with_prev_status/:page_number' => "case#more_open_cases_with_prev_status"
  get '/add_more_special_cases/:page_number' => "case#more_special_cases"
  get '/add_more_special_cases_by_status/:page_number' => "case#more_special_cases_by_status"
  get '/add_more_reprint_or_amended/:page_number' => "case#more_amended_or_reprinted_cases"
  get '/special_cases'=>"case#special_cases"
  get '/printed_special_case' =>"case#printed_special_case"
  get '/rejected_special_case' => "case#rejected_special_case"
  get '/approved_incomplete' => "case#approved_for_print_marked_incomplete"
  get 'view_cases/:person_id' => 'case#show'
  get '/show/:person_id' => 'case#show'
  get '/incomplete_cases' => 'case#incomplete_cases'
  get "/view_certificate/:id" => "case#view_certificate"
  get "/pdf_certificate/:id" => "case#pdf_certificate"
  get '/rejected_cases' => 'case#rejected_cases'
  get "/view_stats" => "case#view_stats"

  #################################Duplicate capturing and resolving routes ##################
  get "/duplicate/:id" =>"case#show_duplicate"
  
  ############################################################
  get "/search" => "hq#search"
  get "/do_search" => "hq#do_search"

  get "/generate_cases" => "hq#generate_cases"
  get "/hq/generate_sample"
  get "/hq/sequencing"
  get "/cause_of_death_list" => "hq#cause_of_death_list"
  get "/illdefined" => "hq#illdefined"  
  get "/nocause_available/:id" => "hq#nocause_available"
  get "/sampled_cases" => "hq#sampled_cases"
  get "/save_proficiency_comment" => "hq#save_proficiency_comment"
  get "/manage_ccu_dispatch" => "hq#manage_ccu_dispatch"
  get "/confirm_ccu_dispatch" => "hq#confirm_ccu_dispatch"
  post "/confirm_dispatch/:dispatch" => "hq#confirm_dispatch"
  get "/confirm_dispatch/:dispatch" => "hq#confirm_dispatch"
  get "/edit_icd_code" => "hq#edit_icd_code"
  get "/review/:id" => "hq#review"
  get "/save_mark" =>"hq#save_mark"
  get "/hq/save_review"
  get "/results/:id" => "hq#results"
  get "/finalizereview/:id" => "hq#finalizereview"
  get "/reviewed/:id/:index" => "hq#reviewed"

  #printing routes
  
  get '/printed_view/:id' => "hq#printed_view"
  
  get "/print_preview" => "hq#print_preview"
  
  get '/death_certificate_print/:id' => "hq#death_certificate_print"
  
  get '/death_certificate/:id' => "hq#death_certificate"
  
  post 'hq/do_print_these'

  get 'hq/do_print_these'

  post 'hq/do_dispatch_these'

  get 'hq/do_dispatch_these'

  get '/dispatch_preview' => "hq#dispatch_preview"

  get 'hq/death_certificate_preview'

  get '/facilities' => "hq#facilities"

  get '/nationalities' => "hq#nationalities"

  get '/countries' => "hq#countries"

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
  get '/hq/quality_control'
  get '/hq/quality_reopen'
  post "/hq/quality_check"
  get  "/hq/quality_check"


  get '/reports' => "reports#index"

  ########Report Tasks starts here #######
  get '/causes_of_death' => "reports#causes_of_death"
  
  get '/manner_of_death' => "reports#manner_of_death"

  get "/proficiency" => "reports#proficiency"

  get "/death_reports" => "reports#death_reports"

  get "/reports/district_and_gender"

  get "/reports/by_district_registered_and_gender"

  get "/reports/place_of_death"

  get "/reports/by_place_of_death"

  post "/reports/download_place_of_death"

  post "/reports/download_cause_of_death"

  get "/reports/user_audits"

  get "/reports/get_audits"



  ######### Causes of Death ##############
  get "/cause_of_death_preview" => "causes_of_death#cause_of_death_preview"
  get "/cause_of_death" => "causes_of_death#cause_of_death"
  get "/save_cause_of_death" => "causes_of_death#save_cause_of_death"
  get "/causes_of_death/view"
  get "/search_causes/:page" => "causes_of_death#search_causes"
  get "/causes_of_death/:id/edit" =>"causes_of_death#edit"
  get "/view_ccu__confirmed_dispatch" => "causes_of_death#view_ccu_confirmed_dispatch"
  get "/view_ccu_dispatch" => "causes_of_death#view_ccu_dispatch"
  post "/causes_of_death/save_review"

  ########## Decentralized printing #######################
  get "/hq/printed_tasks"
  get "/case/dc_printed"
  get "/case/hq_printed"


  ################### COVID 19 ################################

  post "/covid/new" => "causes_of_death#save_covid_record"
  get "/covid/:id" => "causes_of_death#show_covid_record"
  get "/reports/covid"
  get "/reports/covid/count" => "reports#covid_count"

  ################### Dashboard Routes #########################
  get "/deaths" => "reports#deaths"
  get "/api/v1/deaths" => "reports#deaths"
  get "/death_aggregates" => "reports#death_aggregates"
  get "/api/v1/death_aggregates" => "reports#death_aggregates"
  get "/deaths_by_cause" => "reports#deaths_by_cause"
  get "/api/v1/deaths_by_cause" => "reports#deaths_by_cause"
  get "/causes_aggregates" => "report#causes_aggregates"
  get "/api/v1/causes_aggregates" => "reports#causes_aggregates"
  get "/covid_cases" => "reports#covid_cases"
  get "/api/v1/covid_cases" => "reports#covid_cases"
  get "/api/v1/by_district_registered_and_gender" => "reports#by_district_registered_and_gender"
  get "/api/v1/manner_of_death" =>"reports#manner_of_death"
  get "/api/v1/age_disag_by_gender" => "reports#age_disag_by_gender"

  ################## External Verification #############################
  post "/api/v1/verify_certificate" => "api#verify_certificate"

  ################## Sync ##############################################
  post "/dc_sync" => "api#dc_sync"
  post "/api/v1/dc_sync" => "api#dc_sync"

  # The priority is based upoindexation: first created -> highest priority.
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
