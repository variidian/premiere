class ChangeReferralsDefaultToZero < ActiveRecord::Migration[8.1]
  def change
      change_column_default :users, :referrals, from: nil, to: 0
  end
end
