class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    
    create_table :bookings, id: false do |t|
      t.primary_key :booking_id
      t.references :user, null: false, type: :integer, foreign_key: { primary_key: :user_id }, index: false
      t.references :room, null: false, type: :integer, foreign_key: { primary_key: :room_id }, index: false
      t.date :check_in_date, null: false
      t.date :check_out_date, null: false
      t.decimal :total_price, precision: 10, scale: 2, null: false
      t.integer :guests_count, null: false
      t.string :status, default: 'pending'
      t.timestamps
    end
    
    add_index :bookings, :user_id
    add_index :bookings, :room_id
    add_index :bookings, :status
    add_index :bookings, [:room_id, :check_in_date, :check_out_date]
    add_index :bookings, :created_at
    
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE UNIQUE INDEX idx_prevent_double_booking 
          ON bookings (room_id, check_in_date) 
          WHERE status IN ('pending', 'confirmed')
        SQL
        
        execute <<-SQL
          ALTER TABLE bookings 
          ADD CONSTRAINT check_dates 
          CHECK (check_out_date > check_in_date)
        SQL
        
        execute <<-SQL
          ALTER TABLE bookings 
          ADD CONSTRAINT guests_count_check 
          CHECK (guests_count > 0)
        SQL
        
        execute <<-SQL
          ALTER TABLE bookings 
          ADD CONSTRAINT total_price_check 
          CHECK (total_price > 0)
        SQL
      end
    end
  end
end