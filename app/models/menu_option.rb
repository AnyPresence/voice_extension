class MenuOption < ActiveRecord::Base
  belongs_to :account
  
  validates :name, :presence => true
  validates :format, :presence => true
  
  def build_voice_response(digit)
    response_text = self.account.object_instances(name, format)
    response_text = [response_text] unless response_text.kind_of? Array
    response = Twilio::TwiML::Response.new do |r|
      r.Say "You pressed, #{digit}, Geting latest information for #{name.pluralize}", :voice => 'woman'
      
      r.Say "There is an #{name}:", :voice => 'woman'
      response_text.each do |t|
        r.Say "#{t}", :voice => 'woman'
      end
    end
    response
  end
  
  def self.build_menu_option(objects)
    options = {}
    options["1"] = ["menu",""]
    
    objects.each_with_index do |option, index|
      i = index+1
      options[i.to_s] = [option, "Press, #{i}, for, #{option.underscore.humanize}"]
    end
  
    url = ENV['VOICE_CONSUME_URL']
    match = url.match /^http(s?):\/\/.*?\//
    url = match[0].gsub(/\/+$/,'') unless match.nil?
    
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Hello, Welcome to Anypresence's voice system:", :voice => 'woman'
      # List out available object definitions
      options.values.each do |v|
        r.Say v[1].pluralize, :voice => 'woman'
      end
      
      options.keys.each do |k|
        Rails.logger.info "Adding object #{options[k][0]} to gather with digit #{k.to_i}..."
        r.Gather(:action => url + "/menu?object_name=#{options[k][0]}", :numDigits => 1, :finishOnKey => k.to_s) do
        end
      end
    
      # Finished
      r.Say 'Goodbye!', :voice => 'woman'
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
