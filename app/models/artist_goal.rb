class ArtistGoal < ActiveRecord::Base

  before_save :set_default

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'user_id', 'goal_amount','raised_amount','sharing_goal']


  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def set_default
    self.raised_amount=0 unless  self.raised_amount
    
  end


  ## associations ##
  belongs_to :user

  has_many :rewards ,:autosave=>true, :foreign_key=>"artist_goal_id"

  ## validations ##

  # 0-Active; 1-Inactive(Deleted)
  #validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
  validates :goal_amount,:numericality => { :greater_than_or_equal_to => 0 }, :presence => true
  validates :raised_amount,:numericality => { :greater_than_or_equal_to => 0 }, :presence => true
  validates :sharing_goal,:numericality => { :greater_than_or_equal_to => 0 }, :presence => true
  validates :user_id, :uniqueness=>true
 

  def self.persist_fields
    [ 'user_id', 'goal_amount','raised_amount','sharing_goal']
  end

  ## Initialization
  after_initialize :init

  def init
    self.raised_amount = 0 if self.raised_amount.blank?    
    self.sharing_goal = 0 if self.sharing_goal.blank?    
    self.goal_amount = 0 if self.goal_amount.blank?    
  end

end
