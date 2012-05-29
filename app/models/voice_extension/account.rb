module VoiceExtension
  class Account
    include Mongoid::Document
    include Mongoid::Timestamps

    field :consume_phone_number, type: String

    NUM_ENTRIES = 2

  end
end