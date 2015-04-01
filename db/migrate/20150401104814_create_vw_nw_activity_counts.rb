class CreateVwNwActivityCounts < ActiveRecord::Migration
  def change
    create_view :vw_nw_activity_counts, "select  object_id,
			activity_type,
			object_type,
			count(1) as activity_count
			from network_activity_logs
			group by object_id,activity_type,object_type;"
  end
end
