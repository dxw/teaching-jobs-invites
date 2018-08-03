require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'json'
require 'jwt'
require 'logger'

Dir['./services/*.rb'].each {|file| require file }

InviteToTeachingJobs.run!
