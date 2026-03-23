class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms, id: false do |t|
      t.primary_key :room_id
      t.references :hotel, null: false, type: :integer, foreign_key: { primary_key: :hotel_id }, index: false
      t.string :room_number, null: false
      t.string :room_type, null: false
      t.integer :capacity, null: false
      t.decimal :price_per_night, precision: 10, scale: 2, null: false
      t.text :description
      t.string :amenities, array: true, default: []
      t.boolean :is_available, default: true
      t.timestamps
    end
    
    add_index :rooms, :hotel_id
    add_index :rooms, :price_per_night
    add_index :rooms, :room_type
    add_index :rooms, :capacity
    add_index :rooms, [:hotel_id, :room_number], unique: true
    
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE rooms 
          ADD CONSTRAINT capacity_check 
          CHECK (capacity > 0)
        SQL
        
        execute <<-SQL
          ALTER TABLE rooms 
          ADD CONSTRAINT price_check 
          CHECK (price_per_night > 0)
        SQL
      end
    end
  end
end