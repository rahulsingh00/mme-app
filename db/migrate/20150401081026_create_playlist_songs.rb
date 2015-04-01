class CreatePlaylistSongs < ActiveRecord::Migration
  def change
    create_table :playlist_songs do |t|
    	t.integer :user_id, :null=>false
      t.integer :playlist_id, :null=>false
      t.integer :media_id, :null=>false
      t.integer :trashed
      t.timestamps
    end
    add_index :playlist_songs ,[:user_id] ,:name=>'idx_playlist_songs_on_user_id'
		add_index :playlist_songs ,[:playlist_id] ,:name=>'idx_playlist_songs_on_playlist_id'
		add_index :playlist_songs ,[:media_id] ,:name=>'idx_playlist_songs_on_media_id'
  end
end
