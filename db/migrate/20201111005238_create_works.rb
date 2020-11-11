class CreateWorks < ActiveRecord::Migration[6.0]
  def change
    create_table :works do |t|
      t.string :title
      t.string :creator
      t.date :published_year
      t.text :description
      t.string :category

      t.timestamps
    end
  end
end
