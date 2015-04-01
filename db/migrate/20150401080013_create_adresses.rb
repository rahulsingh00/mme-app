class CreateAdresses < ActiveRecord::Migration
  def change
    create_table :adresses do |t|
    	t.string :line_1
      t.string :line_2
      t.string :city, :limit =>100
      t.string :state, :limit => 100
      t.string :country, :limit =>100
      t.integer :zip_code
      t.integer :user_id, :null => false
    end
  end
end
