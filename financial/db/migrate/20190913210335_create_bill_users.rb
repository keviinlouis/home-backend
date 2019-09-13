class CreateBillUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :bill_users do |t|
      t.references :user, foreign_key: true
      t.references :bill, foreign_key: true
      t.float :amount

      t.timestamps
    end
  end
end
