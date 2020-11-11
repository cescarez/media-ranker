class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.date :join_date

      t.timestamps
    end
  end
end
