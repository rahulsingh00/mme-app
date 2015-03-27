class Reward < ActiveRecord::Base

  before_save :set_default

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id','artist_goal_id', 'amount','comment']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def set_default
    #self.raised_amount=0 unless  self.raised_amount

  end

  def self.trash_old_rewards user_id
    criteria = {:user_id => user_id ,:trashed =>0}
    self.update_all({:trashed => 1}, criteria)
  end


  ## associations ##
  belongs_to :user
  belongs_to :artist_goal

  ## validations ##

  # 0-Active; 1-Inactive(Deleted)
  validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
  validates :amount,:numericality => { :greater_than => 0 }, :presence => true
  validates :comment,:presence => true
  validates :user_id, :presence=>true

  #validates_legth_of :comment, :within=> 6..50, :too_long=>" Enter Maximum 50 chars for reward comments", :to_short=>"Enter Minimum 6 chars for Reward Comments"




  def self.persist_fields
    [ 'user_id', 'amount','comment']
  end

  ## Initialization
  after_initialize :init

  def init

  end

end
