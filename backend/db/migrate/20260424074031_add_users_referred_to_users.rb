class AddUsersReferredToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :referrals, :integer
  end
end
