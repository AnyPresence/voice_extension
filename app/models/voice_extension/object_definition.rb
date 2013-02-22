module VoiceExtension
  class ObjectDefinition
    include ActiveModel::MassAssignmentSecurity
    include Mongoid::Document
    include Mongoid::Timestamps
    
    validates :name, presence: true, uniqueness: true
    
    field :name, type: String
    field :query_scope, type: String, default: "all"
    
    has_many :menu_options, class_name: "VoiceExtension::MenuOption", inverse_of: :object_definition
    has_many :pages, class_name: "VoiceExtension::Page", inverse_of: :object_definition
  end
end