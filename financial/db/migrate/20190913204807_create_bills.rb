class CreateBills < ActiveRecord::Migration[5.2]
  def change
    create_table :bills do |t|
      t.float :amount
      t.string :name
      t.text :description
      t.date :expires_at
      t.integer :frequency
      t.integer :frequency_type
      t.references :user, foreign_key: true
      t.references :bill_category, foreign_key: true

      t.timestamps
    end
  end
end
