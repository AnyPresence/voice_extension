VoiceExtension::Application.routes.draw do
  devise_for :accounts

  post 'provision' => 'voice#provision'
  post 'deprovision' => 'voice#deprovision'
  post 'voice' => 'voice#voice'
  post 'publish' => 'voice#publish'
  match 'settings' => 'voice#settings'
  match 'consume' => 'voice#consume'
  
  root :to => 'voice#unauthorized'
  
  devise_for :accounts
end
