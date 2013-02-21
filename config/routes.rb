VoiceExtension::Engine.routes.draw do
  match 'consume' => 'voice#consume'
  get 'settings' => 'pages#index'
  
  resources :pages do
    resources :menu_options
  end
  
  root :to => "pages#index"
end
