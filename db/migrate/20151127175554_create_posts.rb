class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.jsonb :json
      t.references :vgroup, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
