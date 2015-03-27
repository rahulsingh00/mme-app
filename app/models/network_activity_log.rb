class NetworkActivityLog < ActiveRecord::Base

  ## associations ##
  belongs_to :object, :polymorphic => true
  belongs_to :dest_object, :polymorphic => true
  belongs_to :user, :class_name => 'User', :foreign_key =>  "from_user_id"

  # TODO: add validations for object and dest_object
  # TODO: add validations for activity_type

  ## validations ##
  # validates :status, :inclusion => { :in => [0, 1] }, :presence => true

  def self.persist_fields
    [ "from_user_id", "object_id", "object_type", "dest_object_id", "dest_object_type", "activity_type" ]
  end
end