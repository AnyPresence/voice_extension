class MenuOption < ActiveRecord::Base
  def self.build_menu_option(objects)
    #menu_options
    options = {}
    options["1"] = ["menu",""]
    
    objects.each_with_index do |option, index|
      i = index+2
      options[i.to_s] = [option, "Press, #{i}, for, #{option.underscore.humanize}"]
    end
  
    url = ENV['VOICE_CONSUME_URL']
    match = url.match /^http(s?):\/\/.*?\//
    url = match[0].gsub(/\/+$/,'') unless match.nil?
    
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Hello, Welcome to Anypresence's voice system:", :voice => 'woman'
      # List out available object definitions
      options.values.each do |v|
        r.Say v[1], :voice => 'woman'
      end
      
      options.keys.each do |k|
        r.Gather(:action => url + "/menu?object_name=#{options[k][0]}", :numDigits => k.to_i) do
        end
      end
    
      # Finished
      r.Say 'Goodbye!', :voice => 'woman'
    end    
    response    
  end

  
end
