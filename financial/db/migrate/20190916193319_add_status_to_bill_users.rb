class AddStatusToBillUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_users, :status, :integer, default: 0
  end
end
