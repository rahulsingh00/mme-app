class CreateHangoutMedia < ActiveRecord::Migration
  def change
    create_table :hangout_media do |t|
    	t.integer :user_id ,:null=>false
      t.integer :event_id ,:null=>false
      t.integer :media_type ,:null=>false # 0-Image; 1-Audio; 2-Video
      t.string :url  ,:null =>false, :limit => 512
      t.integer :trashed ,:null=>false, :default=>0 # 0-Inactive; 1-Active
      t.timestamps
    end
    add_index :hangout_media ,[:user_id] ,:name=>'idx_hangout_media_on_user_id'
		add_index :hangout_media ,[:event_id] ,:name=>'idx_hangout_media_on_event_id'
		add_index :hangout_media ,[:media_type] ,:name=>'idx_hangout_media_on_media_type'
  end
end
