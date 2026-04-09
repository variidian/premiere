class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :uid
      t.string :name
      t.string :email
      t.string :profile
      t.string :verification_status
      t.string :slack_id

      t.timestamps
    end
  end
end
