class CreateVwPlaylists < ActiveRecord::Migration
  def change
    create_view :vw_playlists, 'select playlist_songs.id,
playlist_songs.media_id,
playlists.id as "playlist_id",
playlists.playlist_name,
playlists.user_id,
vw_media.meta_data,
vw_media.title,
vw_media.url,
vw_media.media_type,
vw_media.user_id as "artist_id",
vw_media.first_name as "artist_first_name",
vw_media.last_name as "artist_last_name",
vw_media.avatar as "artist_avatar",
vw_media.artist_card_bg_image,
vw_media.plays,
vw_media.likes,
vw_media.shares
from playlist_songs
inner join playlists on (playlists.id = playlist_songs.playlist_id and playlist_songs.trashed=0 and playlists.trashed=0)
left outer join vw_media on (playlist_songs.media_id=vw_media.id and playlist_songs.trashed=0);'
  end
end
