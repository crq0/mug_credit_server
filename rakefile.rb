require './models'
require 'sinatra/activerecord/rake'

desc "Resets the Users and Transactions in the database"
task :reset_db do
  User.all.each {|x| x.delete }
  Transaction.all.each {|x| x.delete }
end
