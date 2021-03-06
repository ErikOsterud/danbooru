module Mentionable
  extend ActiveSupport::Concern

  module ClassMethods
    # options:
    # - message_field
    # - user_field
    def mentionable(options = {})
      @mentionable_options = options

      message_field = mentionable_option(:message_field)
      after_save :queue_mention_messages, if: :"#{message_field}_changed?"
    end

    def mentionable_option(key)
      @mentionable_options[key]
    end
  end

  def queue_mention_messages
    message_field = self.class.mentionable_option(:message_field)
    text = send(message_field)
    text_was = send("#{message_field}_was")

    names = DText.parse_mentions(text) - DText.parse_mentions(text_was)

    names.uniq.each do |name|
      body  = self.instance_exec(name, &self.class.mentionable_option(:body))
      title = self.instance_exec(name, &self.class.mentionable_option(:title))

      Dmail.create_automated(to_name: name, title: title, body: body)
    end
  end
end
