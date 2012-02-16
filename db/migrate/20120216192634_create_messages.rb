class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :account_sid
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
