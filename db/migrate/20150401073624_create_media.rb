class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
    	t.integer :user_id ,:null=>false
      t.integer :media_type ,:null=>false # 0-Image; 1-Audio; 2-Video
      t.string :title, :null=>false, :limit => 250
      t.string :desc, :limit => 512
      t.string :url  ,:null =>false, :limit => 512
      t.string :meta_data, :limit => 1024
      t.integer :trashed ,:null=>false, :default=>0 # 0-Inactive; 1-Active
      t.timestamps
    end
    add_index :media, [:user_id], :name=>'idx_media_on_user_id'
  end
end
