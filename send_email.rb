class SendEmail
  def initialize(user)
    @user = user
  end

  def call
    send_welcome_email
  end

  private def notify_client
    Notifications::Client.new(ENV['NOTIFY_KEY'])
  end

  private def send_welcome_email
    notify_client.send_email(
      email_address: @user[:email],
      template_id: ENV['NOTIFY_WELCOME_TEMPLATE_ID'],
      personalisation: {
        first_name: @user[:given_name],
        family_name: @user[:family_name],
        school_name: school_name_or_how_many
      },
      reference: 'welcome-to-teaching-jobs-email'
    )
  end

  private def school_name_or_how_many
    @user[:schools].count > 1 ? "#{@user[:schools].count} schools" : @user[:schools].first[:school_name]
  end
end
