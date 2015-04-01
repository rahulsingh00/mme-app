class CreateNetworkActivityLogs < ActiveRecord::Migration
  def change
    create_table :network_activity_logs do |t|
    	t.integer :from_user_id ,:null=>false
      t.integer :object_id ,:null=>false
      t.string :object_type,:null=>false
      t.integer :dest_object_id ,:null=>false
      t.string :dest_object_type,:null=>false
      t.integer :activity_type,:null=>false
      t.integer :for_user_id ,:null=>false
      t.integer :reachability_count, :default=>1
      t.timestamps
    end
    add_index :network_activity_logs, [:from_user_id] , :name=>'idx_network_activity_on_from_user_id'
		add_index :network_activity_logs, [:for_user_id] , :name=>'idx_network_activity_on_for_user_id'
  end
end
