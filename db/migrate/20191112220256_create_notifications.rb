class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :description
      t.references :user, foreign_key: true
      t.references :resource, polymorphic: true
      t.boolean :opened
      t.timestamp :opened_at
      t.integer :notification_type
      t.string :message_error
      t.integer :status

      t.timestamps
    end
    add_index :notifications, :opened
  end
end
