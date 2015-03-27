class PaymentDetail < ActiveRecord::Base

  before_save :set_default

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'artist_id','amount','stripe_customer_id','payment_reason','status','payment_failed_reason','currency']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def set_default
    self.status ='u' unless self.status
    self.currency='usd' unless self.currency
  end


  ## associations ##
  belongs_to :user

  ## validations ##

  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true

  # u- Uncharged , c-Charged , f- failed
  validates :status, :inclusion => { :in => ['u','c','f'] }, :presence => true
  validates :amount,:numericality => { :greater_than => 0 }, :presence => true
  validates :stripe_customer_id, :presence => true
  validates :payment_reason,:inclusion=>{:in => ['ticket','pledge']} ,:presence => true
  validates :currency,:inclusion=>{:in => ['usd']} ,:presence => true

  def self.create_stripe_customer var_stripe_token, var_email
    Stripe.api_key="sk_test_QSTRRxYirOaBwh0IPMABUKMC"
    # create a stripe Customer
    customer = Stripe::Customer.create(
    :card => var_stripe_token,
    :description => var_email
    )

  end

  def self.charge_card customer_id, charge_amount ,currency="usd"
    #begin
      charge = Stripe::Charge.create(
      :amount => (charge_amount*100).to_i, # in cents
      :currency => currency.downcase,
      :customer => customer_id
      )
    #rescue Stripe::CardError => e
    #  criteria = {:stripe_customer_id => customer_id }
    #  update_all({:status => 'f'}, criteria)
    #end

  end


  def self.persist_fields
    [ 'user_id', 'artist_id','amount','stripe_token','payment_reason','status','payment_failed_reason','currency']
  end

  ## Initialization
  after_initialize :init

  def init
    self.trashed = 0 if self.trashed.blank?
    self.status ='u' if self.status.blank?
    self.currency='usd' if self.currency.blank?
  end

end
