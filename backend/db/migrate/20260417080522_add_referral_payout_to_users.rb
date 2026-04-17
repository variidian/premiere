class AddReferralPayoutToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :referral_paid, :boolean
  end
end
