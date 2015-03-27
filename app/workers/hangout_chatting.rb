require 'erubis'
require 'time'
class ChatMessageDBPusher
  include Sidekiq::Worker
  sidekiq_options queue: :chat_message_saving_queue, :retry => false

  def perform(chat_message_detail)
    logger.info "start :: processing #{self.class} for chat"

    @chat_message_detail = HangoutMessage.new chat_message_detail
    if !@chat_message_detail.save then
      logger.error "chat could not be saved "+@chat_message_detail.errors
    else
      logger.info "end :: chat saved"
    end
  end
end