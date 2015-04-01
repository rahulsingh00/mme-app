class CreateVwArtists < ActiveRecord::Migration
  def change
    create_view :vw_artists, 'select  users.id,
			users.first_name,
			users.last_name ,
			users.email,
			users.phone_number ,
			users.avatar ,
			users.bg_image,
			users.bio ,
			users.desc ,
			users.user_type ,
			users.stage_name,
			users.artist_card_bg_image ,
			users.crowd_role_chosen,
			phase_ledgers.phase as "phase_id",
			COALESCE(sum(like_share_view.likes),0) as "likes",
			COALESCE(sum(like_share_view.shares),0) as "shares",
			COALESCE(sum(like_share_view.plays),0) as "plays",
			COALESCE(sum(like_share_view.users_shared),0) as "users_shared",
			COALESCE(vw_ticket.total_tickets,0) as "total_tickets",
			COALESCE(vw_supporters.total_number_supporters,0) as "number_of_supporters",
			COALESCE(vw_supporters.pledged_amount,0) as "pledged_amount",
			COALESCE(artist_goals.goal_amount,0) as "goal_amount",
			COALESCE(artist_goals.sharing_goal,0) as "sharing_goal",
			vw_images.images,
			users.created_at,
			users.updated_at
			from users
			left outer join phase_ledgers on (phase_ledgers.user_id=users.id and phase_ledgers.trashed=0 )
			left outer join like_share_view on(users.id=like_share_view.for_user_id)
			left outer join (select events.user_id,count(1) as "total_tickets" from events,tickets where tickets.event_id=events.id and tickets.status in (\'booked\') group by events.user_id) as vw_ticket on (vw_ticket.user_id=users.id)
			left outer join (select payment_details.artist_id,count(1) as "total_number_supporters",sum(amount) as "pledged_amount" from  payment_details where payment_details.status in (\'u\',\'c\') group by payment_details.artist_id) as vw_supporters on ( vw_supporters.artist_id=users.id )
			left outer join (select media.user_id,array_agg(media.url) as "images"  from media where media_type = 0 and trashed=0 group by media.user_id ) as vw_images on (users.id=vw_images.user_id)
			left outer join artist_goals on (artist_goals.user_id=users.id)
			where users.trashed=0
			group by users.id,
			users.first_name,
			users.last_name,
			users.email,
			users.phone_number,
			users.avatar,
			users.bg_image,
			users.bio,
			users.desc,
			users.user_type,
			users.stage_name,
			users.artist_card_bg_image,
			phase_ledgers.phase,
			vw_ticket.total_tickets,
			vw_supporters.total_number_supporters,
			vw_images.images,
			users.created_at,
			users.updated_at,
			vw_supporters.pledged_amount,
			artist_goals.goal_amount,
			artist_goals.sharing_goal,
			users.crowd_role_chosen
			;'
  end
end
