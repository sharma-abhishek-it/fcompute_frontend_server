class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :data
      t.references :sector, index: true

      t.timestamps null: false
    end
    add_index :products, :name
    add_foreign_key :products, :sectors
  end
end
