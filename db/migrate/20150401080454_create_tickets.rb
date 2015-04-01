class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
    	t.integer :event_id ,:null=>false
      t.integer :user_id,:null=>false
      t.string :ticket_token,:null=>false
      t.timestamp :booked_at ,:null=>false
      t.integer :payment_txn_id
      t.string :discount_token
      t.float :selling_price ,:null=>false
      t.string :status,:null=>false
      t.string :opentok_role, :limit=>30
		  t.string :user_role, :limit=>30
		  t.integer :used_by_user_id
      t.timestamps
    end
    add_index :tickets ,[:event_id] ,:name=>'idx_tickets_on_event_id'
		add_index :tickets ,[:user_id] ,:name=>'idx_tickets_on_user_id'
		add_index :tickets ,[:ticket_token] ,:name=>'idx_tickets_on_ticket_token'
		add_index :tickets ,[:user_role] ,:name=>'idx_opentok_details_on_user_role'
		add_index :tickets ,[:opentok_role] ,:name=>'idx_opentok_details_on_opentok_role'
		add_index :tickets ,[:used_by_user_id] ,:name=>'idx_opentok_details_on_used_by_user_id'
  end
end
