class CreateVwEvents < ActiveRecord::Migration
  def change
    create_view :vw_events, 'select events.id,
			events.user_id,
			events.title,
			events.description,
			events.total_seats,
			events.event_type,
			events.start_time,
			events.end_time,
			events.price_per_seat,
			events.image,
			users.avatar as "artist_avatar",
			users.first_name as "artist_first_name",
			users.last_name as "artist_last_name",
			events.opentok_session_id,
			COALESCE(q.tickets_sold,0) as "tickets_sold"
			from events
			inner join users on (users.id=events.user_id and events.trashed=0 and users.trashed=0 and users.user_type>0)
			left outer join  (select event_id,count(1) as "tickets_sold" from tickets where status in (\'pending\',\'booked\',\'viewing\',\'used\') group by event_id) as q
			on (q.event_id=events.id and events.trashed=0)
			;'
  end
end
