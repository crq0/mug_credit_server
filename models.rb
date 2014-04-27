require 'active_record'
require 'uri'
require './pbkdf2'
require 'digest'

def get_rand
    rand = "";
    File.open("/dev/urandom").read(20).each_byte{|x| rand << sprintf("%02x",x)}
    rand
end

class User < ActiveRecord::Base
  has_many :transactions
  validates :username, :phash, presence: true

  def self.login(username, password)
    user = User.find_by_username(username)
    return nil if not user

    if hash_password(password, user.salt) == user.phash
      token = generate_token(user)
      user.token = token
      user.save
      return token
    else
      return nil
    end
  end

  def self.generate_token(user)
    user.token = (Digest::SHA2.new << (user.username + Time.now.to_s)).to_s
    user.token_expires = Time.now + (24*365)
    user.save
    return user.token
  end

  def self.hash_password(password, salt)
    p = PBKDF2.new do |p|
        p.iterations = 10000
        p.password = password
        p.salt = salt
        p.key_length = 160/8
    end
    p.hex_string
  end
end

class Transaction < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :created, :amount, :thash, presence: true
  validates :thash, uniqueness: true
end


db = URI.parse('mysql2://kaley:password@localhost/mug_credit')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'mysql2' ? 'mysql2' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)
