class AddAuthIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :auth_id, :string
  end
end
