class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :hackatime_project, null: false
      t.string :repository_url
      t.string :demo_url
      t.string :status, null: false, default: 'draft'
      t.datetime :submitted_at
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
