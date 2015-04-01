require 'api_extension'
require 'api_decorator'

class Playlist < Grape::API

  helpers RestHelpers
  # use ApiDecorator

  # version 'v1', :using => :header, :vendor => 'mme', :format => :json, :strict => true
  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  # rescue_from :all do |error|
  #   logger.error "API << #{env['REQUEST_METHOD']} #{env['PATH_INFO']} -- #{error.class.name} -- #{error.message}"
  #   logger.error "API << Last error's backtrace:\n#{error.backtrace.join("\n")}"
  #   headers = { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*', 'Access-Control-Request-Method' => '*' }
  #   rack_response({ error: [error.class.name], message: [error.message] }.to_json, 500, headers)
  # end

  resource 'users' do
    desc "Create Playlist"
    post ":id/playlist/create" do

      playlist_params = filter_params(params,Playlist.persist_fields)
      logger.debug playlist_params
      errors = nil

      @playlist = Playlist.new playlist_params
      raise_rest_error_with_status(423,@playlist.errors.messages) if !@playlist.save

      status 201
      @playlist
    end

    desc "add songs to playlist"
    post ":id/playlists" do
      playlist_song_params = filter_params(params,PlaylistSong.persist_fields)
      logger.info playlist_song_params
      playlist_song_params["user_id"] = params[:id]

      if playlist_song_params['playlist_id'].blank? then
        #playlist_params= {:user_id=>playlist_song_params[:id], }
        playlist = Playlist.where(:user_id=>params[:id],:trashed=>0).first
        if playlist.blank? then
          #create and return play list id
          playlist= Playlist.new :user_id=>params[:id]
          raise_rest_error_with_status(423,playlist.errors.full_messages) if !playlist.save
        end
        playlist_song_params["playlist_id"]=playlist.id

      end

      logger.debug playlist_song_params

      existing_same_song = PlaylistSong.where(:playlist_id=>playlist_song_params["playlist_id"],:media_id=>playlist_song_params["media_id"],:trashed=>0)

      if !existing_same_song.blank?
        raise_rest_error_with_status(200,"Song already part of this playlist")
      else

        @playlist_song= PlaylistSong.new playlist_song_params
        raise_rest_error_with_status(423,@playlist_song.errors.full_messages) if !@playlist_song.save
        status 201
        @playlist_song
      end
    end




    desc "Delete playlist songs", {
      :params =>
      {
        "playlist_songs_id" => { :desc => "Playlist songs Identifier(s)", :type => "long" }
      }
    }
    delete ":id/playlists/:playlist_songs_id" do
      criteria = {:user_id => params[:id] ,:trashed =>0}
      criteria.merge!(:id => params[:playlist_songs_id]) #unless playlist_songs_id.blank?
      PlaylistSong.update_all({:trashed => 1}, criteria)
      status 200
      {}
    end



    desc "Get playlists for User", {
      :params =>
      {
        "id" => { :desc => "User Identifier", :type => "long" },
        "playlist_ids" => {:desc => "playlist Identifier", :type => "long" }
      }
    }
    get ":id/playlists" do
      logger.info params
      #user= User.find(params[:id])
      #play_list_ids =parse_csv_as_int_array(params[:playlist_ids])

      conditions, arguments = [], {}

      conditions << 'user_id = :user_id'
      arguments[:user_id] = params[:id].to_i

      all_conditions = conditions.join(' AND ')

      #all_condition = {:user_id => params[:id]}
      #all_condition [:playlist_id => play_list_ids ] if !play_list_ids.blank?

      play_list_songs= {}
      return_array = []
      # PlaylistSong.find(:all, :conditions=>{:user_id=>params[:id], :trashed=>0}).each do |pl|
      VwPlaylist.find(:all, :conditions=>{:user_id=>params[:id]}).each do |pl|
        logger.debug "#{pl.as_json}"
        if play_list_songs[pl.playlist_id].blank? then
          play_list_songs[pl.playlist_id]=[pl]
        else
          play_list_songs[pl.playlist_id] << pl
        end
      end
      #play_list_songs
      play_list_songs.each do |key, value|
        return_array << {:playlist=>key,:songs=>value}
      end
      return_array
    end



  end
end
