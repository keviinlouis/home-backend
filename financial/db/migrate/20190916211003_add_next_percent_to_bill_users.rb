class AddNextPercentToBillUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_users, :next_percent, :float
  end
end
