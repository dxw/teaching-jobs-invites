require 'csv'

class InviteToTeachingJobs
  def self.run!
    rows = []
    options = { encoding: 'UTF-8', skip_blanks: true, headers: true }
    CSV.foreach(user_data_file_name, options) do |row|
      rows << row.to_h.transform_keys!(&:to_sym)
    end

    users = CsvRowsToUser.new(rows).transform

    results = users.map do |user|
      create_invite = CreateInvite.new(user: user)
      create_invite.call
    end

    logger = Logger.new($stdout)
    logger.info("Successful: #{results.compact.count}")
    logger.info("Failed: #{results.count - results.compact.count}")
  end

  def self.user_data_file_name
    'users.csv'
  end
end
