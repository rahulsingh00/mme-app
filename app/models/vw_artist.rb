class VwArtist < ActiveRecord::Base

  DEFAULT_FIELDS_TO_DISPLAY = ['id', 'first_name', 'last_name', 'email', 'phone_number',
  'avatar', 'bg_image', 'artist_card_bg_image' , 'bio', 'desc', 'user_type', 'stage_name','phase_id' ,'images','stats','crowd_role_chosen']

  #associations
  has_many :supporting_crowds, :class_name=>'ArtistCrowdSupportLevel' , :foreign_key=>'artist_id', :conditions => ['trashed = ?', 0]
  has_many :supported_artists, :class_name=>'ArtistCrowdSupportLevel' , :foreign_key=>'crowd_id',:conditions => ['trashed = ?', 0]

  has_many :supporting_crowd_details, :class_name=> 'VwCrowdSupporter' , :foreign_key=>'artist_id'

  

  def attributes
    @display_fields ||= DEFAULT_FIELDS_TO_DISPLAY.to_ahash
  end

  def supporter_levels
    crowd_levles=CrowdDoerLevel.where(:trashed=>0)
    crowd_levles_fin= []
    crowd_role_chosen= self.crowd_role_chosen
    crowd_role_chosen="" if crowd_role_chosen.blank?
    chosen_levels= crowd_role_chosen.split(',').map { |x| x.to_i }
    crowd_levles.each do |crc|
      cl=crc.as_json
      if cl['id'].in?(chosen_levels) then
        cl['is_selected']=true
      else
        cl['is_selected']=false
      end
      crowd_levles_fin << cl
    end
    crowd_levles_fin
  end

  def stats  	
  	{:likes=>self.likes.to_i,:shares=>self.shares.to_i,:plays=>self.plays.to_i,:total_tickets=>self.total_tickets.to_i,:number_of_supporters=>self.number_of_supporters.to_i,:pledged_amount=>self.pledged_amount,:goal_amount=>self.goal_amount,:sharing_goal=>self.sharing_goal,:users_shared=>self.users_shared.to_i}
  end

end
