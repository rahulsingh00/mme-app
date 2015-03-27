require 'erubis'
require 'time'
class CrowdDoerLevelUpdater
  include Sidekiq::Worker
  sidekiq_options queue: :crowd_doer_level_update_queue, :retry => false

  def perform(crowd_ids, artist_id)
    crowd_ids.each do |crowd_id|
      puts "start :: processing #{self.class} for crowd : #{crowd_id} and artist : #{artist_id} "

      crowd_activity = VwCrowdActivity.where(:from_user_id=> crowd_id, :for_user_id=> artist_id)
      shares=0
      funding=0.0
      crowd_activity.each do |ca|
        shares+=ca.sum.to_i if ca.activity == "shares"
        funding+=ca.sum.to_f if ca.activity == "funding"
      end
      crowd_role_chosen =  User.find_by_id(artist_id).crowd_role_chosen
      crowd_role_chosen = "" if crowd_role_chosen.blank?
      #chosen_levels= User.find_by_id(artist_id).crowd_role_chosen.split(',').map { |x| x.to_i }
      chosen_levels= crowd_role_chosen.split(',').map { |x| x.to_i }

      elegible_levels=CrowdDoerLevel.where("shares <= ? and funding <= ?",shares,funding).pluck(:id)


      crowd_level = (elegible_levels & chosen_levels).sort.last.to_i

      if crowd_level == 0 then
        puts " crowd #{crowd_id} is not elegible to be at any level Yet for artist #{artist_id}"
        next
      end
      puts "crowd level to be assigned is #{crowd_level}"

      crowd_level_already_set =!ArtistCrowdSupportLevel.where(:artist_id=>artist_id,:crowd_id=>crowd_id,:crowd_doer_level_id=>crowd_level,:trashed=>0).last.blank?
      if crowd_level_already_set then
        puts "Crowd is already in the level #{crowd_level} .Nothing to Set"
        next
      end
      acs=ArtistCrowdSupportLevel.new :artist_id=> artist_id,:crowd_id=>crowd_id,:crowd_doer_level_id=>crowd_level
      ## update crowd Level  for the crowd-artist
      if !acs.save then
        puts acs.errors
        next
      end
      puts "end :: crowd level updated  for crowd_id#{crowd_id} and artist_id #{artist_id}"
    end

  end
end