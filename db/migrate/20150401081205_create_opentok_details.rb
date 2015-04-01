class CreateOpentokDetails < ActiveRecord::Migration
  def change
    create_table :opentok_details do |t|
    	t.integer :user_id, :null=>false
			t.integer :event_id , :null=>false
			t.string :session_id , :null=>false, :limit=>512
			t.string :ticket_code, :null=>false,:limit=>16
			t.string :token,:limit=>512
			#t.string :opentok_role , :null=>false
			t.timestamp :token_expires_at
			t.timestamps
    end
    add_index :opentok_details ,[:user_id] ,:name=>'idx_opentok_details_on_user_id'
		add_index :opentok_details ,[:event_id] ,:name=>'idx_opentok_details_on_event_id'
		add_index :opentok_details ,[:session_id] ,:name=>'idx_opentok_details_on_session_id'
		add_index :opentok_details ,[:ticket_code] ,:name=>'idx_opentok_details_on_ticket_code'
		add_index :opentok_details ,[:token_expires_at] ,:name=>'idx_opentok_details_on_token_expires_at'
  end
end
