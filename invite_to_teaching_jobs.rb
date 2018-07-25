require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'json'
require 'jwt'
require './create_invite'

users = [
  {email: 'robbie.paul+2@dxw.com', given_name: 'Robbie', family_name: 'Paul', school_urn: '137138'},
  {email: 'robbie.paul+15@dxw.com', given_name: 'Robbie', family_name: 'Paul', school_urn: '137138'},
  {email: 'robbie.paul+16@dxw.com', given_name: 'Robbie', family_name: 'Paul', school_urn: '137138'},
]

def generate_jwt_token
  payload = {
    iss: 'schooljobs',
    exp: (Time.now + 60).to_i,
    aud: 'signin.education.gov.uk'
  }
  JWT.encode payload, ENV['DFE_SIGN_IN_API_PASSWORD'], 'HS256'
end

results = users.map do |user|
  create_invite = CreateInvite.new(user: user, jwt_token: generate_jwt_token)
  create_invite.call
end

puts ''
puts "Successful: #{results.compact.count}"
puts "Failed: #{results.count - results.compact.count}"