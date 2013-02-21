module VoiceExtension
  class ObjectDefinition
    include ActiveModel::MassAssignmentSecurity
    include Mongoid::Document
    include Mongoid::Timestamps
    
    validates :name, presence: true, uniqueness: true
    
    field :name, type: String
    
    has_many :menu_options, class_name: "VoiceExtension::MenuOption", inverse_of: :object_definition
    
  end
end