module VoiceExtension
  class Page
    include Mongoid::Document
    include Mongoid::Timestamps
    
    field :name, type: String
    
    has_many :menu_options, class_name: "VoiceExtension::MenuOption", inverse_of: :page
    
    belongs_to :from_menu_option, class_name: "VoiceExtension::MenuOption", inverse_of: :forward_page
  end
end
