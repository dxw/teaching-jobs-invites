class SendEmail
  def initialize(user)
    @user = user
  end

  def call
    if @user[:schools].count > 1
      send_trust_welcome_email
    else
      send_single_welcome_email
    end
  end

  private

  def notify_client
    Notifications::Client.new(ENV['NOTIFY_KEY'])
  end

  def send_single_welcome_email
    notify_client.send_email(
      email_address: @user[:email],
      template_id: ENV['NOTIFY_WELCOME_SINGLE_TEMPLATE_ID'],
      personalisation: {
        email_address: @user[:email],
        first_name: @user[:given_name],
        family_name: @user[:family_name],
        school_name: @user[:schools].first[:school_name]
      },
      reference: 'welcome-to-teaching-jobs-email'
    )
    Logger.new($stdout).info("Sent welcome email to #{@user[:email]} for #{@user[:schools].first[:school_name]}")
  end

  def send_trust_welcome_email
    notify_client.send_email(
      email_address: @user[:email],
      template_id: ENV['NOTIFY_WELCOME_TRUST_TEMPLATE_ID'],
      personalisation: {
        email_address: @user[:email],
        first_name: @user[:given_name],
        family_name: @user[:family_name],
        school_name: "#{@user[:schools].count} schools",
        trust_name: @user[:trust_name] || 'your trust'
      },
      reference: 'welcome-to-teaching-jobs-email'
    )
    Logger.new($stdout).info("Sent welcome email to #{@user[:email]} for #{@user[:schools].count} schools")
  end
end
