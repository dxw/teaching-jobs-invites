class FailedUsers < Array

    def log_csv
        CSV.open('failed-users.csv', 'wb') do |csv|
            csv << ['school_urn','given_name','family_name','email','school_name','trust_name']
            self.each do |r|
                csv << r.values
            end
        end
    end

end