require './services/csv_rows_to_user'

RSpec.describe CsvRowsToUser do
  describe '#transform' do
    let(:rows) do
      [
        {email: 'email@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Macmillan Academy', school_urn: '137138'},
        {email: 'email@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Macmillan Primary', school_urn: '137139'},
        {email: 'email@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Macmillan Secondary', school_urn: '137140'},
        {email: 'something@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Other Academy', school_urn: '137140'},
      ]
    end
    let(:csv_rows_to_user) { CsvRowsToUser.new(rows) }
    subject(:transformed_users) { csv_rows_to_user.transform }

    it 'groups the rows by email' do
      expect(transformed_users.count).to eql(2)
    end

    it 'contains user information' do
      expect(transformed_users.first).to include(:email, :family_name, :given_name)
    end

    it 'has a list of schools for each user' do
      expect(transformed_users.first).to include(schools: [
        {school_name: 'Macmillan Academy', school_urn: '137138'},
        {school_name: 'Macmillan Primary', school_urn: '137139'},
        {school_name: 'Macmillan Secondary', school_urn: '137140'},
      ])
      expect(transformed_users.last).to include(schools: [
        {school_name: 'Other Academy', school_urn: '137140'},
      ])
    end
  end
end
