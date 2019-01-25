require 'csv'

class CsvRowsToUser
  attr_reader :users
  attr_reader :errors

  SCHOOL_COLUMNS = [:school_urn, :school_name]

  def initialize(user_data_file_name)
    @users = []
    @errors = []
    options = { encoding: 'UTF-8', skip_blanks: true, headers: true }
    csv = CSV.open(user_data_file_name, options)
    [:convert, :header_convert].each { |c| csv.send(c) { |f| f&.strip } }

    csv.each_with_index do |row, index|
      @users << row_to_user(row, index + 1)
    end
  end

  def row_to_user(row, row_number)
    user = row.to_h.transform_keys!(&:to_sym)
    validate_user(user, row_number)    
    user
  end

  def validate_user(user, row_number)
    [:email, :given_name, :family_name, :school_name].each do |col|    
      @errors << "Missing #{col} at row #{row_number}" if !user[col] || user[col].empty?
    end
    @errors << "Invalid email at row #{row_number}" if email_invalid?(user[:email])
  end

  def email_invalid?(email)
    !email.nil? && !email.match(URI::MailTo::EMAIL_REGEXP)
  end

  def unique_users
    @users.group_by{|row| row[:email] }.map do |rows|
      rows_belonging_to_user = rows[1]
      user = filter_out_school_columns(rows_belonging_to_user.first)
      user[:schools] = sideload_schools(rows_belonging_to_user)
      user
    end
  end

  private

  def sideload_schools(rows_belonging_to_user)
    rows_belonging_to_user.map do |row|
      row.select {|k, _v| SCHOOL_COLUMNS.include?(k)}
    end
  end

  def filter_out_school_columns(row)
    row.reject {|k, _v| SCHOOL_COLUMNS.include?(k)}
  end
end
