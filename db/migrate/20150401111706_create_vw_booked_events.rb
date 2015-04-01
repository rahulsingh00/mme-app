class CreateVwBookedEvents < ActiveRecord::Migration
  def change
    create_view :vw_booked_events, 'select vw_events.id as "event_id",
			tickets.user_id,
			vw_events.title,
			vw_events.description,
			vw_events.total_seats,
			vw_events.event_type,
			vw_events.start_time,
			vw_events.end_time,
			vw_events.price_per_seat,
			vw_events.artist_avatar,
			vw_events.artist_first_name,
			vw_events.artist_last_name,
			vw_events.opentok_session_id,
			vw_events.tickets_sold,
			vw_events.image,
			string_agg(tickets.ticket_token,\',\') as "tickets",
			string_agg(tickets.opentok_role,\',\') as "ticket_roles"
			from vw_events
			inner join tickets on (tickets.event_id=vw_events.id  and tickets.status in (\'booked\',\'viewing\',\'used\'))
			group by vw_events.id,
			tickets.user_id,
			vw_events.title,
			vw_events.description,
			vw_events.total_seats,
			vw_events.event_type,
			vw_events.start_time,
			vw_events.end_time,
			vw_events.price_per_seat,
			vw_events.artist_avatar,
			vw_events.artist_first_name,
			vw_events.artist_last_name,
			vw_events.opentok_session_id,
			vw_events.tickets_sold,
			vw_events.image
			;'
  end
end
