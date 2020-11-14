class RemoveJoinDateFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :join_date
  end
end
