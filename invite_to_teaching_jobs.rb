require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'json'
require 'jwt'
require './create_invite'
require './csv_rows_to_user'
require 'csv'

rows = []
options = { encoding: 'UTF-8', skip_blanks: true, headers: true }
CSV.foreach('users.csv', options) do |row|
  rows << row.to_h.transform_keys!(&:to_sym)
end

users = CsvRowsToUser.new(rows).transform

results = users.map do |user|
  create_invite = CreateInvite.new(user: user)
  create_invite.call
end

puts ''
puts "Successful: #{results.compact.count}"
puts "Failed: #{results.count - results.compact.count}"
