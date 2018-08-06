class CsvRowsToUser
  SCHOOL_COLUMNS = [:school_urn, :school_name]

  def initialize(rows)
    @rows = rows
  end

  def transform
    @rows.group_by{|row| row[:email] }.map do |rows|
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