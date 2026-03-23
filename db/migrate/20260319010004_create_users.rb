class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL
      DO $$ BEGIN
        CREATE TYPE user_role AS ENUM ('admin', 'user');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    SQL
    
    create_table :users, id: false do |t|
      t.primary_key :user_id
      t.string :username, null: false
      t.string :email, null: false
      t.string :password_hash, null: false
      t.string :phone
      t.string :role, default: 'user'
      t.boolean :has_visa, default: false
      t.timestamps
    end
    
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :role
  end
end