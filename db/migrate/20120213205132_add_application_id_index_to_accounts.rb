class AddApplicationIdIndexToAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, :application_id, :unique => true
  end
end
