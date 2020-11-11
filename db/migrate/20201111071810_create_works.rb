class CreateWorks < ActiveRecord::Migration[6.0]
  def change
    create_table :works do |t|
      t.string :category
      t.string :title
      t.string :creator
      t.date :publication_year
      t.text :description

      t.timestamps
    end
  end
end
