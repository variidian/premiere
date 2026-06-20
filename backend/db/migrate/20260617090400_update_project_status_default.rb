class UpdateProjectStatusDefault < ActiveRecord::Migration[8.1]
  def up
    change_column_default :projects, :status, from: 'draft', to: 'not_yet_shipped'
    Project.where(status: 'draft').update_all(status: 'not_yet_shipped')
    Project.where(status: 'submitted').update_all(status: 'pending_approval')
    Project.where(status: 'accepted').update_all(status: 'approved')
  end

  def down
    change_column_default :projects, :status, from: 'not_yet_shipped', to: 'draft'
    Project.where(status: 'not_yet_shipped').update_all(status: 'draft')
    Project.where(status: 'pending_approval').update_all(status: 'submitted')
    Project.where(status: 'approved').update_all(status: 'accepted')
  end
end
