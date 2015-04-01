class CreatePhaseLedgers < ActiveRecord::Migration
  def change
    create_table :phase_ledgers do |t|
    	t.integer :user_id, :null=>false
      t.integer :phase #1-audition 2-contest ...
      t.integer :trashed, :null => false, :default=>0 # 0-active; 1- inactive
      t.timestamp :activated_at, :null=>false
      t.timestamp :deactivated_at
      t.timestamps
    end
    add_index :phase_ledgers ,[:user_id], :name=>'idx_phase_ledgers_on_user_id'
  end
end
