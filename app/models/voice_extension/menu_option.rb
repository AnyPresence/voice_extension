module VoiceExtension
  class MenuOption
    include Mongoid::Document
    include Mongoid::Timestamps
    
    GENERIC_ERROR_MESSAGE_TO_VOICE = "Sorry, we're unable to process the request at this time."
    
    belongs_to :page, class_name: "VoiceExtension::Page", inverse_of: :menu_options
    
    validates :keyed_value, :format, presence: true
    validates :keyed_value, uniqueness: {scope: :page}
    
    field :keyed_value, type: String
    field :name, type: String
    field :format, type: String
    
    # A menu option has one forward page transition
    has_one :forward_page, class_name: "VoiceExtension::Page", inverse_of: :from_menu_option
  
    # Builds the menu option to be read of to the caller.
    #
    # Params:
    # +pressed_value+ is the pressed key value. If there's key press, speak out
    #   the main menu.
    # +page+ is the page which displayed the options that resulted in this key press.
    def self.build_menu_option(pressed_value=nil, page=nil)
      url = ENV['VOICE_CONSUME_URL']
      # match = url.match /^http(s?):\/\/.*?\//
      # url = match[0].gsub(/\/+$/,'') unless match.nil?
      
      response = nil
      if pressed_value.blank?
        response = Twilio::TwiML::Response.new do |r|
          r.Say "Hello, Welcome to Anypresence's voice system:", :voice => 'woman'
        
          r.Say "Press the pound key after you are done keying in your selection.", :voice => 'woman'
        
          # Get root page
          page = VoiceExtension::Page.root_page.first
          page.menu_options.order_by('keyed_value ASC').each do |option|
            r.Say "Press #{option.keyed_value} for #{option.format}", :voice => 'woman'
          end

          r.Gather(:action => "#{url}?current_page=#{page.name}", :timeout => 5) 
    
          # Finished
          r.Say 'Goodbye!', :voice => 'woman'
        end    
      else # We have a key press
        response = Twilio::TwiML::Response.new do |r|
          r.Say "You pressed: #{pressed_value}", :voice => 'woman'
          
          # Get page for key'ed value
          menu_option = page.menu_options.where(keyed_value: pressed_value).first
          if menu_option.blank? && menu_option.forward_page.blank?
            Rails.logger.error "There's no page to transition to."
            r.Say GENERIC_ERROR_MESSAGE_TO_VOICE, :voice => 'woman'
          else
            next_page = menu_option.forward_page
            next_page.menu_options.order_by('keyed_value ASC').each do |option|
              r.Say "Press #{option.keyed_value} for #{option.format}", :voice => 'woman'
            end
            
            r.Gather(:action => "#{url}?current_page=#{next_page.name}", :timeout => 5) 
          end
          
        end
      end
      response    
    end
  
  
    # Parse format string from menu options
    # The input string uses the Liquid template format, e.g. "Outage: {{title}} : {{description}}".
    # 'title' and 'description' are attributes for the 'outage' object.
    #   If the attributes for a particular outage object are: title => "Widespread Outage", description => "Around D.C. area."
    #   Then the rendered text should be "Outage: Widespread Outage : Around D.C. area".
    def self.parse_format_string(format, object_name, decoded_json)
      klass = self.build_liquid_drop_class(object_name, decoded_json.keys)
      # Set instance variables for klass from decoded json
      klass_instance = klass.new(decoded_json)
    
      vars = klass_instance.instance_variables.map {|v| v.to_s[1..-1] }
      liquid_hash = {}
      vars.each do |v|
        liquid_hash[v] = klass_instance.send v
      end
    
      liquid_hash[object_name.downcase] = klass_instance
      Liquid::Template.parse(format).render(liquid_hash)
    end

    # Builds a liquid drop class from the object_name
    def self.build_liquid_drop_class(object_name, fields)
      klass = Class.new(Liquid::Drop) do
        define_method(:initialize) do |arg|
          arg.each do |k,v|
            instance_variable_set("@#{k}", v)
          end
        end
      
        fields.each do |field|
          define_method("#{field}=") do |arg|
            instance_variable_set("@#{field}", arg)
          end
          define_method field do
            instance_variable_get("@#{field}")
          end
        end
      end
      klass
    end

  
  end
end