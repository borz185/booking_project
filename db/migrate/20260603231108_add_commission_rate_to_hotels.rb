class AddCommissionRateToHotels < ActiveRecord::Migration[7.2]
  def change
    add_column :hotels, :commission_rate, :decimal, precision: 5, scale: 2, default: 15.0, null: false
    # commission_rate будет хранить процент, например 15.00 = 15%
  end
end