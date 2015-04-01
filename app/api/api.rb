require 'grape-swagger'
class API < Grape::API
  prefix 'api'
  version 'v1', using: :path
  mount Event
  mount User
  mount Payment
  mount Goal
  mount Media
  mount Playlist
  mount Share
  mount Ticket
  add_swagger_documentation
end
