class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false do |t|
      t.string :id, null: false
      t.string :name
      t.string :email

      t.timestamps
    end

    add_index "users", ["id"], name: "index_users_on_id", unique: true, using: :btree
  end
end
