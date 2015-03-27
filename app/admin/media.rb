ActiveAdmin.register Media do
  index do
	column :id
	column :user_id
	column :title
	column :desc
	column :media_type

	column :media_type do |media|
	  if media.media_type == 0
	  	"Image"
	  elsif media.media_type == 1
	  	"Audio"
	  else
	  	"Video"
	  end
    end

	column :trashed do |media|
      media.trashed == 0 ? "Active" : "Inactive"
    end
	default_actions
  end
end