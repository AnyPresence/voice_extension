VoiceExtension::Application.routes.draw do
  devise_for :accounts

  post 'provision' => 'voice#provision'
  post 'deprovision' => 'voice#deprovision'
  post 'voice' => 'voice#voice'
  post 'publish' => 'voice#publish'
  match 'generate_consume_phone_number' => 'voice#generate_consume_phone_number'
  match 'settings' => 'voice#settings'
  match 'consume' => 'voice#consume'
  match 'menu' => 'voice#menu'
  
  root :to => 'voice#unauthorized'
  
  devise_for :accounts
  
  resources :accounts do
    resources :menu_options, :controller => "menu_option", :type => "MenuOption"
  end
end
