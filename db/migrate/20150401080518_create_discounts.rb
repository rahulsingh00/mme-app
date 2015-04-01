class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
    	t.integer :event_id ,:null=>false
      t.string :discount_token,:null=>false
      t.string :discount_type,:null=>false
      t.float :discount_value,:null=>false, :default=>0
      t.timestamp :valid_from_time, :null=>false
      t.timestamp :valid_till_time
      t.boolean :is_active, :null=>false ,:default=>true

      t.timestamps
    end
  end
end
