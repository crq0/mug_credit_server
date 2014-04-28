# spec/spec_helper.rb
require 'rack/test'
require 'factory_girl'

require File.expand_path '../../server.rb', __FILE__

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include RSpecMixin
end

FactoryGirl.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
FactoryGirl.find_definitions

# Wipe out database
User.all.each {|x| x.delete }
Transaction.all.each {|x| x.delete }

def login
  u = create(:user)
  post "/login?username=#{u.username}&password=abc123"
  JSON.parse(last_response.body)["token"]
end

