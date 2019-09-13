class AddDeletedAtToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :deleted_at, :datetime
    add_index :bills, :deleted_at
  end
end
