class CreateEarnings < ActiveRecord::Migration[7.2]
  def change
    create_table :earnings do |t|
      # Используем bigint и указываем связи вручную, так как PK не стандартные
      t.bigint :booking_id, null: false
      t.bigint :hotel_id, null: false
      
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :commission_rate, precision: 5, scale: 2, null: false
      t.datetime :earned_at, null: false

      t.timestamps
    end
    
    add_index :earnings, :booking_id
    add_index :earnings, :hotel_id
    add_index :earnings, :earned_at
    
    # Явно указываем, на какие колонки ссылаться
    add_foreign_key :earnings, :bookings, column: :booking_id, primary_key: :booking_id
    add_foreign_key :earnings, :hotels, column: :hotel_id, primary_key: :hotel_id
  end
end