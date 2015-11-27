class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.jsonb :json
      t.references :attachmentable, polymorphic: true, index: true
      t.text :attachment_type
      t.timestamps null: false
    end
  end
end
