class AddNextAmountToBillUsersTable < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_users, :next_amount, :float
  end
end
