VoiceExtension::Engine.routes.draw do
  post 'consume' => 'voice#consume'
  get 'settings' => 'settings#index'
  post 'modify_settings' => "settings#update"
  
  resources :pages do
    resources :menu_options
  end
  
  root :to => "settings#index"
end
