class RelateVotestoWorks < ActiveRecord::Migration[6.0]
  def change
    add_reference :votes, :work, index: true
  end
end
