class AddHackatimeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :hackatime_uid, :string
    add_column :users, :hackatime_access_token, :string
    add_column :users, :hackatime_refresh_token, :string
    add_column :users, :hackatime_expires_at, :datetime
  end
end
