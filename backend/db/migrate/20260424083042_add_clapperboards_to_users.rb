class AddClapperboardsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :clapperboards, :integer, default: 0
  end
end
