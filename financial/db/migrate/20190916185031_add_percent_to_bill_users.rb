class AddPercentToBillUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_users, :percent, :float
  end
end
