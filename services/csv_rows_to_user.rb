require 'csv'
class CsvRowsToUser
  SCHOOL_COLUMNS = [:school_urn, :school_name]

  def initialize(user_data_file_name)
    @users = []
    options = { encoding: 'UTF-8', skip_blanks: true, headers: true }
    csv = CSV.open(user_data_file_name, options)
    [:convert, :header_convert].each { |c| csv.send(c) { |f| f&.strip } }

    csv.each do |row|
      @users << row.to_h.transform_keys!(&:to_sym)
    end
  end

  def users
    @users
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
