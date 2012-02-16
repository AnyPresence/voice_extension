class AddConsumePhoneNumberStringToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :consume_phone_number, :string

  end
end
