class CreateVwCrowdActivities < ActiveRecord::Migration
  def change
    create_view :vw_crowd_activities, '(select from_user_id,
			for_user_id,
			case
			when activity_type=1 then \'plays\'
			when activity_type=2 then \'likes\'
			when activity_type=3 then \'shares\'
			end as "activity"
			,sum(reachability_count) as "sum" from network_activity_logs
			group by from_user_id,for_user_id,activity_type) UNION
			(select user_id as "from_user_id" ,
			artist_id as "for_user_id",
			\'funding\'::varchar as "activity",
			sum(amount) as "sum"
			from payment_details
			where status in (\'u\',\'c\')
			     and trashed=0
			group by "from_user_id","for_user_id","activity");'
  end
end
