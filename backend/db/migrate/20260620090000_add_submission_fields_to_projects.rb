class AddSubmissionFieldsToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :image_url, :string
    add_column :projects, :hackatime_hours, :decimal, precision: 8, scale: 2
    change_column_null :projects, :hackatime_project, true
  end
end
