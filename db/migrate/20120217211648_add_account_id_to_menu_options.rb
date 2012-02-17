class AddAccountIdToMenuOptions < ActiveRecord::Migration
  def change
    add_column :menu_options, :account_id, :integer
  end
end
