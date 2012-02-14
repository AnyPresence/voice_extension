class CreateMenuOptions < ActiveRecord::Migration
  def change
    create_table :menu_options do |t|
      t.string :name
      t.string :format

      t.timestamps
    end
  end
end
