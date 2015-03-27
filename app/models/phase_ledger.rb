class PhaseLedger < ActiveRecord::Base

	before_save :set_default, :trash_old_phase

	after_save :phase_record_is_unique

	def set_default
		self.activated_at =Time.now unless self.activated_at
		self.phase = 1 unless self.phase
	end

	def trash_old_phase
		criteria = {:user_id => self.user_id ,:trashed =>0}
		self.class.update_all({:trashed => 1 , :deactivated_at => Time.now}, criteria)
	end

	## associations ##
	belongs_to :user , :polymorphic=>true

	## validations ##
	# 0-Active; 1-Inactive(Deleted)
	validates :trashed, :inclusion => { :in => [0, 1] }, :presence => true
	validate :validate_time_stamps
	#validates_uniqueness_of :user_id ,:scope => :phase
	#validate :phase_record_is_unique


	def validate_time_stamps
		if !activated_at.blank? && activated_at < Time.now then
			errors.add(:invalid_date, "activated_at can not be a past date")
		end
		#if  (!deactivated_at.blank? && deactivated_at < Time.now) then
		#		errors.add(:invalid_date," deactivated_at can not be a past date")
		#end
		if !activated_at.blank? && !deactivated_at.blank? && activated_at > deactivated_at then
			errors.add(:invalid_date,"activated_at can not be future to deactivated_at")
		end
	end

	def phase_record_is_unique
		unless PhaseLedger.where(:user_id => self.user_id, :trashed=>0).count ==0
			errors.add(:invalid_phase_record,"there can not be two active phase of a user at same time")
		end
	end


	def self.persist_fields
		[ "user_id", "phase","trashed", "activated_at", "deactivated_at" ]
	end

	def to_s
    	self.phase.to_s
  end  
end