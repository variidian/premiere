class AddReferredByToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :referred_by, :string
  end
end
