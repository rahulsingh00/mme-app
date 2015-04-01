class CreateArtistCrowdSupportLevels < ActiveRecord::Migration
  def change
    create_table :artist_crowd_support_levels do |t|
    	t.integer   :artist_id ,:null=>false
      t.integer   :crowd_id ,:null=>false
      t.integer   :crowd_doer_level_id ,:null=>false #text,media
      t.integer   :trashed ,:null=>false, :default=>0 # 0-Inactive; 1-Active
      t.timestamp :activated_at
      t.timestamp :deactivated_at
      t.timestamps
    end
  end
end
