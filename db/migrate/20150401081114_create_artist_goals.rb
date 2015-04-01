class CreateArtistGoals < ActiveRecord::Migration
  def change
    create_table :artist_goals do |t|
    	t.integer :user_id, :null=>false
      t.float :goal_amount , :null=>false
      t.float :raised_amount , :null=>false
      t.integer :sharing_goal, :default=>0
      t.timestamps
    end
    add_index :artist_goals ,[:user_id] ,:name=>'idx_artist_goals_on_user_id'
		add_index :artist_goals ,[:goal_amount] ,:name=>'idx_artist_goals_on_goal_amount'
		add_index :artist_goals ,[:raised_amount] ,:name=>'idx_artist_goals_on_rasied_amount'
  end
end
