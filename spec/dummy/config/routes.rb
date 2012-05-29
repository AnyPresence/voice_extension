Rails.application.routes.draw do

  resources :outages

  mount VoiceExtension::Engine => "/voice_extension"
end
