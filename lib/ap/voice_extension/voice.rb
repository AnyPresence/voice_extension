module AP
  module VoiceExtension
    def self.config_account(config={})
      if config.empty?
        raise "Nothing to configure!"
      end
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
  end
end