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

  context 'invalid data' do
    let(:errors) { csv_rows_to_user.errors }

    context 'with a missing email' do
      let(:csv_file) { "./spec/fixtures/missing_email.csv" }

      it 'returns an error' do
        expect(errors.count).to eq(1)
        expect(errors.first).to eq('Missing email at row 1')
      end
    end

    context 'with a missing first name' do
      let(:csv_file) { "./spec/fixtures/missing_first_name.csv" }

      it 'returns an error' do
        expect(errors.count).to eq(1)
        expect(errors.first).to eq('Missing given_name at row 1')
      end
    end

    context 'with a missing last name' do
      let(:csv_file) { "./spec/fixtures/missing_last_name.csv" }

      it 'returns an error' do
        expect(errors.count).to eq(1)
        expect(errors.first).to eq('Missing family_name at row 1')
      end
    end

    context 'with a missing school' do
      let(:csv_file) { "./spec/fixtures/missing_school.csv" }

      it 'returns an error' do
        expect(errors.count).to eq(1)
        expect(errors.first).to eq('Missing school_name at row 1')
      end
    end

    context 'with an invalid email' do
      let(:csv_file) { "./spec/fixtures/invalid_email.csv" }

      it 'returns an error' do
        expect(errors.count).to eq(1)
        expect(errors.first).to eq('Invalid email at row 1')
      end
    end

    context 'with multiple rows' do
      let(:csv_file) { "./spec/fixtures/multiple_errors.csv" }

      it 'returns errors' do
        expect(errors.count).to eq(3)
      end
    end
  end

end
