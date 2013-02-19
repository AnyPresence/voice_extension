VoiceExtension::Engine.routes.draw do
  match 'consume' => 'voice#consume'
  get 'settings' => 'settings#index'
  
  resources :menu_options
  
  root :to => "settings#index"
end
