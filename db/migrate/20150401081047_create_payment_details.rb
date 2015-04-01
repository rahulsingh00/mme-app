class CreatePaymentDetails < ActiveRecord::Migration
  def change
    create_table :payment_details do |t|
    	t.integer :user_id, :null=>false
      t.integer :artist_id , :null=>false
      t.float :amount , :null=>false
      t.string :stripe_token,:null=>false
      t.string :stripe_customer_id ,:null=>false
      t.string :payment_reason, :null=>false
      t.string :status , :null=>false
      t.string :payment_failed_reason
      t.integer :trashed ,:null=>false
      t.string :currency , :null=>false
      t.timestamps
    end
    add_index :payment_details ,[:user_id] ,:name=>'idx_payment_details_on_user_id'
		add_index :payment_details ,[:artist_id] ,:name=>'idx_payment_details_on_artist_id'
		add_index :payment_details ,[:stripe_customer_id] ,:name=>'idx_payment_details_on_stripe_customer_id'
		add_index :payment_details ,[:status] ,:name=>'idx_payment_details_on_status'
		add_index :payment_details ,[:trashed] ,:name=>'idx_payment_details_on_trashed'
  end
end
