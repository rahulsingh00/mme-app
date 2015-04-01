class CreateLikeShareView < ActiveRecord::Migration
  def change
    create_view :like_share_view, 'select	v.object_id,
			v.object_type,
			v.for_user_id,
			MAX(CASE WHEN v.activity_type=1 then v.activity_count else 0 end ) as "plays",
			MAX(CASE WHEN v.activity_type=2 then v.activity_count else 0 end ) as "likes",
			MAX(CASE WHEN v.activity_type=3 then v.activity_count else 0 end ) as "shares",
			MAX(CASE WHEN v.activity_type=1 then v.user_count else 0 end ) as "users_played",
			MAX(CASE WHEN v.activity_type=2 then v.user_count else 0 end ) as "users_liked",
			MAX(CASE WHEN v.activity_type=3 then v.user_count else 0 end ) as "users_shared"
			from (select object_id,activity_type,object_type,for_user_id,sum(reachability_count) as activity_count,count(1) as user_count
			from network_activity_logs
			group by object_id,activity_type,object_type,for_user_id
			order by object_id,activity_type
			)v
			group by v.object_id,v.object_type,v.for_user_id
			order by v.object_id,v.object_type;'
  end
end
