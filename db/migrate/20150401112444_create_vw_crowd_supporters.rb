class CreateVwCrowdSupporters < ActiveRecord::Migration
  def change
    create_view :vw_crowd_supporters, 'select artist_crowd_support_levels.crowd_id ,
		  users.first_name as "crowd_first_name",
		  users.last_name as "crowd_last_name",
		  users.email as "crowd_email",
		  artist_crowd_support_levels.artist_id,
		  artist_crowd_support_levels.crowd_doer_level_id as "support_level",
		  artist_crowd_support_levels.activated_at,
		  users.avatar as  "crowd_avatar"
			from artist_crowd_support_levels
			inner join users on users.id= artist_crowd_support_levels.crowd_id
			where users.trashed= 0 and artist_crowd_support_levels.trashed=0;'
  end
end
