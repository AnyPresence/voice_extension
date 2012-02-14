class AddApplicationIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :application_id, :string

  end
end
