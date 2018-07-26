class SendEmail
  def initialize(user)
    @user = user
  end

  def call
    notify_client.send_email(
      email_address: @user[:email],
      template_id: ENV['NOTIFY_TEMPLATE_ID'],
      personalisation: {
        first_name: @user[:given_name],
        school_name: @user[:school]
      },
      reference: 'welcome-to-teaching-jobs-email'
    )
  end

  private def notify_client
    Notifications::Client.new(ENV['NOTIFY_KEY'])
  end
end
