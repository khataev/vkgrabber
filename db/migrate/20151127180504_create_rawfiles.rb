class CreateRawfiles < ActiveRecord::Migration
  def change
    create_table :rawfiles do |t|
      t.binary :data
      t.text :tag
      t.references :attachment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
