class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :first_name ,:null=>false, :limit=> 20
      t.string :last_name ,:null=>false, :limit=> 20
      t.string :email,:null=>false, :limit=> 50
      t.string :phone_number,:null=>false, :limit=> 10
      #t.string :password, :default=>""
      t.string :avatar
      t.string :bg_image
      t.string :bio, :null => true, :limit => 512
      t.string :desc, :limit => 1024
      t.integer :user_type, :default => 1 # 0- Normal; 1-Solo; 2-Band; 3-Freak
      t.string :stage_name, :null=>true, :limit => 20 # Stage name for artists.
      t.string :password_digest, :limit=>512,:default=>""
      t.string :reset_password_token, :limit=>512
      t.timestamp :password_reset_requested_at
      # t.integer :active_phase, :null => false # Audition - 0; Contest - 1; Funding = 2
      t.integer :trashed, :default => 0 # 0-Active; 1- Inactive
      t.string :artist_card_bg_image
      t.string :crowd_role_chosen, :limit=>30
      t.timestamps
    end
    add_index :users ,[:email] ,:name=>'idx_users_on_email'
		add_index :users ,[:phone_number] ,:name=>'idx_users_phone_number'
		add_index :users ,[:reset_password_token] ,:name=>'idx_users_reset_password_token'
  end
end
