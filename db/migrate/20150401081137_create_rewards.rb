class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
    	t.integer :user_id, :null=>false
      t.integer :artist_goal_id , :null=>false
      t.float :amount , :null=>false
      t.string :comment , :null=>false
      t.integer :trashed , :null=>false ,:default=>0
      t.timestamps
    end
    add_index :rewards ,[:user_id] ,:name=>'idx_rewards_on_user_id'
		add_index :rewards ,[:artist_goal_id] ,:name=>'idx_rewards_on_artist_goal_id'
  end
end
