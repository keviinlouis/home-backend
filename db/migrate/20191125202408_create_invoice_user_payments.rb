class CreateInvoiceUserPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :invoice_user_payments do |t|
      t.float :amount
      t.references :invoice_user, foreign_key: true
      t.string :document_path

      t.timestamps
    end
  end
end
