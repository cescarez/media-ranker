class AddDateToVotes < ActiveRecord::Migration[6.0]
  def change
    add_column :votes, :submit_date, :date
  end
end
