class CreateBillEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :bill_events do |t|
      t.integer :kind
      t.text :message
      t.references :user, foreign_key: true
      t.references :bill, foreign_key: true
      t.jsonb :info
      t.jsonb :readed_by
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
