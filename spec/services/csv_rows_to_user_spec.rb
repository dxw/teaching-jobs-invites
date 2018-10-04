require './services/csv_rows_to_user'

RSpec.describe CsvRowsToUser do
  let(:csv_file) { "./spec/fixtures/test_users_with_whitespaces.csv" }
  let(:csv_rows_to_user) { CsvRowsToUser.new(csv_file) }

  describe '#users' do
    let(:users) do
      [
        {email: 'email@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Macmillan Academy', school_urn: '137138', trust_name: 'CPE', other: nil},
        {email: 'email@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Macmillan Primary', school_urn: '137139', trust_name: 'CPE', other: nil},
        {email: 'email@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Macmillan Secondary', school_urn: '137140', trust_name: 'CPE', other: nil},
        {email: 'something@digital.education.gov.uk', given_name: 'Test', family_name: 'Tester', school_name: 'Other Academy', school_urn: '137140', trust_name: 'CPE', other: nil},
      ]
    end

    it 'returns list of converted and cleaned up users' do
      expect(csv_rows_to_user.users).to eq users
    end
  end

  describe '#unique_users' do
    subject(:unique_users) { csv_rows_to_user.unique_users }

    it 'groups the rows by email' do
      expect(unique_users.count).to eql(2)
    end

    it 'contains user information' do
      expect(unique_users.first).to include(:email, :family_name, :given_name)
    end

    it 'has a list of schools for each user' do
      expect(unique_users.first).to include(schools: [
        {school_name: 'Macmillan Academy', school_urn: '137138'},
        {school_name: 'Macmillan Primary', school_urn: '137139'},
        {school_name: 'Macmillan Secondary', school_urn: '137140'},
      ])
      expect(unique_users.last).to include(schools: [
        {school_name: 'Other Academy', school_urn: '137140'},
      ])
    end
  end
end
