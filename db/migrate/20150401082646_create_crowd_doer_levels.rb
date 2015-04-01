class CreateCrowdDoerLevels < ActiveRecord::Migration
  def change
    create_table :crowd_doer_levels do |t|
    	t.string  :level_name ,:null=>false
      t.string  :level_desc ,:limit=>2048
      t.integer :shares ,:null=>false
      t.float   :funding ,:null=>false #text,media
      t.string  :perks,:limit=>256
      t.integer :max_participants
      t.integer :trashed ,:null=>false, :default=>0 # 0-Inactive; 1-Active
      t.timestamps
    end
  end
end
