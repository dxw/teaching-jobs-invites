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

results = users.map do |user|
  create_invite = CreateInvite.new(user: user)
  create_invite.call
end

puts ''
puts "Successful: #{results.compact.count}"
puts "Failed: #{results.count - results.compact.count}"