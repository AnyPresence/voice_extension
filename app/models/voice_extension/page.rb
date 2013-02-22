module VoiceExtension
  class Page
    include Mongoid::Document
    include Mongoid::Timestamps
    
    field :name, type: String
    field :root, type: Boolean, default: false
    field :text_to_voice, type:String
    
    validates :name, uniqueness: true
    
    scope :root_page, where(root: true)
    
    has_many :menu_options, class_name: "VoiceExtension::MenuOption", inverse_of: :page
    
    belongs_to :from_menu_option, class_name: "VoiceExtension::MenuOption", inverse_of: :forward_page
    belongs_to :object_definition, class_name: "VoiceExtension::ObjectDefinition", inverse_of: :pages
    
    # Returns string to voice with values interpolated from object instances
    def speak
      object_instance = object_instances.last
      Liquid::Template.parse(text_to_voice).render(object_instance.try(:attributes))
    end
    
  protected
  
    # Fetches object instances with given query scope for the object.
    def object_instances
      return [] if object_definition.blank?
      
      latest_version = ::AP::VoiceExtension::Voice::Config.instance.latest_version
      klazz = "::#{latest_version.upcase}::#{object_definition.name}".constantize
      query_scope = object_definition.query_scope
      objects = klazz.respond_to?(query_scope.to_sym) ? klazz.send(query_scope.to_sym) : []
      if objects.blank?
        return []
      else
        return objects
      end
    end
    
  end
end
