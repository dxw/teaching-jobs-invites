class CsvRowsToUser
  def initialize(rows)
    @rows = rows
  end

  def transform
    @rows.group_by { |row| row[:email] }.map do |rows|
      user_rows = rows[1]
      user = user_rows.first.select {|k,_v| [:email, :given_name, :family_name].include?(k) }
      user[:schools] = user_rows.map do |entry|
        entry.select {|k,_v| [:school_urn, :school_name].include?(k) }
      end
      user
    end
  end
end