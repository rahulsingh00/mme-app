class NetworkActivityLog < ActiveRecord::Base

  #before_save :check_unique_likes

  ## associations ##
  belongs_to :object, :polymorphic => true
  belongs_to :dest_object, :polymorphic => true
  belongs_to :user, :class_name => 'User', :foreign_key =>  "from_user_id"

    

  ## validations ##
  # 1 : Play    2:Like  ,3:share
   validates :activity_type, :inclusion => { :in => [1,2,3] }, :presence => true
   

   def unique_like?
      (NetworkActivityLog.where(:from_user_id=>self.from_user_id,:activity_type=>2,:object_id=>self.object_id, :object_type=>self.object_type).count == 0) ? true : false
   end

  def self.persist_fields
    [ "from_user_id", "object_id", "object_type", "dest_object_id", "dest_object_type", "activity_type" , "reachability_count"]
  end
end