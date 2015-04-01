class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
    	t.integer :user_id,:null=>false
      t.string :playlist_name,:null=>false
      t.integer :trashed
      t.timestamps
    end
    add_index :playlists ,[:user_id] ,:name=>'idx_playlists_on_user_id'
		add_index :playlists ,[:trashed] ,:name=>'idx_playlists_on_trashed'
  end
end
