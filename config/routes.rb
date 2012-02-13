VoiceExtension::Application.routes.draw do
  post 'provision' => 'voice#provision'
  post 'deprovision' => 'voice#deprovision'
  post 'publish' => 'voice#publish'
  match 'settings' => 'voice#settings'
  match 'consume' => 'voice#consume'
  
  root :to => 'voice#unauthorized'
end
