class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.float :amount
      t.timestamp :expires_at
      t.integer :number
      t.references :bill, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
