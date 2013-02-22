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
    
    belongs_to :object_definition, class_name: "VoiceExtension::ObjectDefinition", inverse_of: :menu_options
  
    # Builds the menu option to be read of to the caller.
    #
    # Params:
    # +pressed_value+ is the pressed key value. If there's key press, speak out
    #   the main menu.
    # +page+ is the page which displayed the options that resulted in this key press.
    def self.build_menu_option(pressed_value=nil, page=nil)
      url = ENV['AP_IVR_NOTIFIER_CONSUME_URL']
      # match = url.match /^http(s?):\/\/.*?\//
      # url = match[0].gsub(/\/+$/,'') unless match.nil?
      
      response = nil
      if pressed_value.blank?
        response = Twilio::TwiML::Response.new do |r|        
          # Get root page
          page = VoiceExtension::Page.root_page.first
          if page.text_to_voice.blank?
            # Say default
            r.Say "Hello, Welcome to Anypresence's voice system:", :voice => 'woman'
            r.Say "Press the pound key after you are done keying in your selection.", :voice => 'woman'
          else
            r.Say page.speak, :voice => 'woman'
          end
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
          
          # Get page for key'ed value and voice it out
          menu_option = page.menu_options.where(keyed_value: pressed_value).first
          if menu_option.blank? && menu_option.forward_page.blank?
            Rails.logger.error "There's no page to transition to."
            r.Say GENERIC_ERROR_MESSAGE_TO_VOICE, :voice => 'woman'
          else
            next_page = menu_option.forward_page
            if next_page
              to_say = next_page.speak
              Rails.logger.info "Will say: #{to_say}"
              r.Say to_say, :voice => 'woman' if !next_page.text_to_voice.blank?
            end
            if next_page && !next_page.menu_options.blank?
              next_page.menu_options.order_by('keyed_value ASC').each do |option|
                r.Say "Press #{option.keyed_value} for #{option.format}", :voice => 'woman'
              end
            
              r.Gather(:action => "#{url}?current_page=#{next_page.name}", :timeout => 5) 
            end
          end
          
        end
      end
      response    
    end

  end
end