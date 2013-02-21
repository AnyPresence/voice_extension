FactoryGirl.define do
  factory :menu_option do
    keyed_value "0"
    name 'outage'
    format '{{title}} : {{description}}'
  end
end