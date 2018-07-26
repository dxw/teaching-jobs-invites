require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'json'
require 'jwt'
require './create_invite'

users = [
  {email: 'tom.hipkin+45@digital.education.gov.uk', given_name: 'Tom', family_name: 'Hipkin', school_name: 'Macmillan Academy', school_urn: '137138'},
]

results = users.map do |user|
  create_invite = CreateInvite.new(user: user)
  create_invite.call
end

puts ''
puts "Successful: #{results.compact.count}"
puts "Failed: #{results.count - results.compact.count}"
