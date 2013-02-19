Rails.application.routes.draw do
  match "admin" => "admin#index", :as => :admin_root
  get '/admin/extensions' => 'admin#index', :as => :admin_extensions
  
  resources :outages
  
  namespace :api do
    mount VoiceExtension::Engine => "/voice_extension"
  end
end
