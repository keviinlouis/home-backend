class CreateDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.references :user, foreign_key: true
      t.text :fcm_token
      t.integer :deivce_type

      t.timestamps
    end
  end
end
