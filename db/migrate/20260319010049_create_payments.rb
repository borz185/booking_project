class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL
      DO $$ BEGIN
        CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    SQL
    
    execute <<-SQL
      DO $$ BEGIN
        CREATE TYPE payment_method AS ENUM ('card', 'cash');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    SQL
    
    create_table :payments, id: false do |t|
      t.primary_key :payment_id
      t.references :booking, null: false, type: :integer, foreign_key: { primary_key: :booking_id }, index: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :payment_method, default: 'card'
      t.string :payment_status, default: 'pending'
      t.string :transaction_id
      t.timestamp :paid_at
      t.timestamps
    end
    
    add_index :payments, :booking_id
    add_index :payments, :payment_status
    add_index :payments, :payment_method
    add_index :payments, :transaction_id, unique: true
    add_index :payments, :paid_at
    
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE payments 
          ADD CONSTRAINT amount_check 
          CHECK (amount > 0)
        SQL
      end
    end
  end
end