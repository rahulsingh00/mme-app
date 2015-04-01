class CreateVwMedia < ActiveRecord::Migration
  def change
    create_view :vw_media, 'select media.id,
			media.user_id,
			media.media_type,
			media.title,
			media.desc,
			media.url,
			media.meta_data,
			media.created_at,
			media.updated_at,
			users.first_name,
			users.last_name,
			users.avatar,
			users.artist_card_bg_image,
			phase_ledgers.phase as "phase_id",
			COALESCE(like_share_view.plays,0) as "plays",
			COALESCE(like_share_view.likes,0) as "likes",
			COALESCE(like_share_view.shares,0) as "shares",
			COALESCE(vw_payments.raised_amount,0) as "raised_amount"
			from media
			inner join users on (media.user_id=users.id and users.trashed=0)
			left outer join like_share_view on(media.id=like_share_view.object_id and like_share_view.object_type=\'Media\')
			left outer join phase_ledgers on (phase_ledgers.user_id=media.user_id and phase_ledgers.trashed=0 )
			left outer join vw_payments on (vw_payments.artist_id = media.user_id)
			where media.trashed=0
			;'
  end
end
