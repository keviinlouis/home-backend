class CreateInvoiceUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_users do |t|
      t.float :amount
      t.timestamp :expires_at
      t.integer :status
      t.references :user, foreign_key: true, type: :string
      t.references :invoice, foreign_key: true
      t.references :bill_user, foreign_key: true

      t.timestamps
    end
  end
end
