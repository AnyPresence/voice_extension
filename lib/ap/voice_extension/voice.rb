require 'singleton'

module AP
  module VoiceExtension
    module Voice
      def self.config_account(config={})
        twilio_account_sid = ENV['SMS_EXTENSION_TWILIO_ACCOUNT_SID']
        twilio_account_sid = ENV['AP_SMS_NOTIFIER_TWILIO_ACCOUNT_SID']
      
        Config.instance.configuration ||= HashWithIndifferentAccess.new
        
        account = nil
        if !::VoiceExtension::Account.all.blank?
          account = ::VoiceExtension::Account.first
          account.update_attributes(config)
        else
          account = ::VoiceExtension::Account.new(config)
          account.save!
        end

        menu_options = config[:menu_options] 
        if !menu_options.nil?
          menu_options.each do |m|
            menu_option = account.menu_options.build(m)
            menu_option.save
          end
        end
        
      end

      class Config
        include Singleton
        attr_accessor :configuration
      end
      
    end
  end
end