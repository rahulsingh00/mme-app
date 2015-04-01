class CreateHangoutMessages < ActiveRecord::Migration
  def change
    create_table :hangout_messages do |t|
    	t.integer :user_id ,:null=>false
      t.integer :event_id ,:null=>false
      t.string :message_type ,:null=>false #text,media
      t.string :message_body,:null=>false,:limit=>2048
      t.boolean :is_artist ,:null=>false, :default=>false # 0-Inactive; 1-Active
      t.integer :trashed ,:null=>false, :default=>0 # 0-Inactive; 1-Active
      t.timestamps
    end
    add_index :hangout_messages, [:user_id]
    add_index :hangout_messages, [:event_id]
    add_index :hangout_messages, [:trashed]
  end
end
