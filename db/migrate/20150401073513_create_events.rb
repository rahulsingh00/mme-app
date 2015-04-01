class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
    	t.string :title ,:limit=>256
      t.string :description ,:limit=>512
      t.integer :user_id, :null=>false
      t.string :venue ,:limit=>512
      t.integer :total_seats ,:null=>false ,:default=>0
      t.string :event_type,:null=>false ,:limit=>20
      t.timestamp :start_time , :null=>false
      t.timestamp :end_time, :null=>false
      t.float :price_per_seat ,:null=>false ,:default=>0
      t.integer :trashed,:null=>false ,:default=>0
      t.string :opentok_session_id, :limit=>512
      t.string :image, :default=>""
      t.timestamps
    end
    add_index :events, [:user_id], :name=>'idx_events_on_user_id'
		add_index :events, [:start_time], :name=>'idx_events_on_start_time'
		add_index :events, [:end_time], :name=>'idx_events_on_end_time'
		add_index :events ,[:opentok_session_id] ,:name=>'idx_events_opentok_session'
  end
end
