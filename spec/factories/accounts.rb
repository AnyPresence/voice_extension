FactoryGirl.define do
  factory :account, :class => VoiceExtension::Account do
    application_id "4f204040772c96c4d3000006"
    api_host "http://localhost:5000"
    extension_id "12345"
  end
end