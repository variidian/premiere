class AddTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :token, :string
  end
end
