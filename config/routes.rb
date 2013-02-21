VoiceExtension::Engine.routes.draw do
  post 'consume' => 'voice#consume'
  get 'settings' => 'pages#index'
  
  resources :pages do
    resources :menu_options
  end
  
  root :to => "pages#index"
end
