class CreateDevlogs < ActiveRecord::Migration[8.1]
  def change
    create_table :devlogs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
