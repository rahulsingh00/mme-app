ActiveAdmin.register CrowdDoerLevel do

  form do |f|
    f.inputs do
      f.input :level_name
      f.input :level_desc, as: :html_editor
      f.input :shares
      f.input :funding
      f.input :perks, as: :html_editor
      f.input :max_participants
    end

    f.buttons
  end
end