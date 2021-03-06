class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :username, null: false
      t.string   :email, null: false, unique: true
      t.string   :password_hash, null: false
      t.integer  :role, default: 0
      t.timestamps
    end
  end
end
