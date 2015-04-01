class CreateSocialConnects < ActiveRecord::Migration
  def change
    create_table :social_connects do |t|
    	t.integer :user_id, :null=>false
      t.string :network_id,   :limit => 100,                :null => false
      t.string :access_token,:null => false
      t.integer :network_type, :default=>1 # 1-Twitter; 2-Facebook; 0-Email
      t.string :screen_name, :limit => 250
      t.integer :network_type, :null => false
      t.string :secret
      t.timestamps
    end
    add_index :social_connects, [:user_id, :network_id], :name=>'idx_social_connects_on_user_id_and_network_id'
    add_index :social_connects ,[:user_id] ,:name=>'idx_social_connects_on_user_id'
		add_index :social_connects ,[:access_token] ,:name=>'idx_social_connects_on_access_token'
  end
end
