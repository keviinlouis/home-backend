class AddNextInvoiceJidToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :next_invoice_jid, :string
  end
end
