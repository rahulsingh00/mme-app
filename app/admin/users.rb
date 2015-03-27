ActiveAdmin.register User do
  actions :all, :except => [:destroy]

  scope :all, :default => true
  scope :artist_users
  scope :crowd_users

  index do
    column :id
    column "Name", :first_name do |artist|
      if artist[:last_name].nil?
        artist[:first_name]
      else
        artist[:first_name] + " " + artist[:last_name]
      end

    end

    column :avatar do |artist|
      image_tag(artist.avatar, :size => "50x50", :alt => "Avatar")
    end

	  column "Likes", :stats do |artist|
      artist.stats[:likes]
    end

    column "Shares", :stats do |artist|
      artist.stats[:shares]
    end

    column "Current Phase", :phase_id

    column "", :id do |artist|
      link_to "View Artist", "http://mme-int.liftoffllc.in/home#/a/" + artist.id.to_s, :target => "_blank"
    end

    column "Status", :trashed do |user|
      user.trashed == 0 ? "Active" : "Inactive"
    end
		actions
	end

  action_item :only => :show do
    user = User.find(params[:id])
    if(user.trashed == 0)
      link_to('Disable User', lock_admin_user_path, method: :put)
    else
      link_to('Enable User', unlock_admin_user_path, method: :put)
    end
  end

  action_item :only => :show do
    user = User.find(params[:id])
    if(user.trashed == 0)
      if(user.phase_id.to_s.eql?("1"))
        link_to('Move to Funding Phase', funding_admin_user_path, method: :put)
      elsif(user.phase_id.to_s.eql?("2"))
        link_to('Move to Development Phase', development_admin_user_path, method: :put)
      end
    end
  end

  member_action :lock, :method => :put do
    user = User.find(params[:id])
    user.trashed = 1
    user.save
    redirect_to(admin_users_path, :notice => "User has been disabled")
  end

  member_action :unlock, :method => :put do
    user = User.find(params[:id])
    user.trashed = 0
    user.save
    # MatchOp.enable_user(params[:id])
    redirect_to(admin_users_path, :notice => "User has been Enabled")
  end

  member_action :funding, :method => :put do
    user = User.find(params[:id])

    phase_param=  {:phase =>2}
    phase_ledger=PhaseLedger.new phase_param
    user.phase_ledgers << phase_ledger

    logger.debug user.phase_ledgers.to_json
    user.save

    # MatchOp.enable_user(params[:id])
    redirect_to(admin_users_path, :notice => "Phase Changed to Funding")
  end

  member_action :development, :method => :put do
    user = User.find(params[:id])

    phase_param=  {:phase =>3}
    phase_ledger=PhaseLedger.new phase_param
    user.phase_ledgers << phase_ledger

    logger.debug user.phase_ledgers.to_json
    user.save

    # MatchOp.enable_user(params[:id])
    redirect_to(admin_users_path, :notice => "Phase Changed to Development")
  end

  form do |f|
    f.inputs "Details" do
      if f.object.new_record?
        f.input :first_name
        f.input :last_name
        f.input :email
        f.input :phone_number
        f.input :bio
        f.input :desc
        f.input :stage_name
        f.input :avatar
      else
        f.input :first_name
        f.input :last_name
        f.input :email
        f.input :phone_number
        f.input :bio
        f.input :desc
        f.input :stage_name

        f.inputs "Artist Goals", :for => [:artist_goal, f.object.artist_goal || ArtistGoal.new] do |goals_form|
          goals_form.input :goal_amount
          goals_form.input :sharing_goal
        end
      end
    end
    f.actions
  end


  filter :first_name
  filter :last_name
  filter :email

  class Array
    def to_ahash
      Hash[*self.collect { |v| [v, v]}.flatten]
    end
  end
end
