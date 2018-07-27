require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'json'
require 'jwt'
require './create_invite'
require 'csv'

users = []
options = { encoding: 'UTF-8', skip_blanks: true }
CSV.foreach('users.csv', options).with_index do |row, i|
  next if i.zero?
  user = {
    email: row[0],
    given_name: row[1],
    family_name: row[2],
    school_name: row[3],
    school_urn: row[4]
  }
  users << user
end

results = users.map do |user|
  create_invite = CreateInvite.new(user: user)
  create_invite.call
end

puts ''
puts "Successful: #{results.compact.count}"
puts "Failed: #{results.count - results.compact.count}"
