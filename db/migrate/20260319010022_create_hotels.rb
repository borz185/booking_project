class CreateHotels < ActiveRecord::Migration[7.0]
  def change
    create_table :hotels, id: false do |t|
      t.primary_key :hotel_id
      t.string :name, null: false
      t.string :city, null: false
      t.string :country, null: false
      t.string :address, null: false
      t.integer :stars
      t.text :description
      t.string :phone
      t.boolean :visa_required, default: false
      t.timestamps
    end
    
    add_index :hotels, :city
    add_index :hotels, :country
    add_index :hotels, :stars
    
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE hotels 
          ADD CONSTRAINT stars_check 
          CHECK (stars >= 1 AND stars <= 5)
        SQL
      end
    end
  end
end