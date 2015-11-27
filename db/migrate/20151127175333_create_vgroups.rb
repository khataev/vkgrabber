class CreateVgroups < ActiveRecord::Migration
  def change
    create_table :vgroups do |t|
      t.integer :vk_id
      t.jsonb :json

      t.timestamps null: false
    end
  end
end
