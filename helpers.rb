require 'json'
require 'digest'

def to_json(hash)
  JSON.generate(hash)
end

def json_error(msg)
  halt [500, to_json({error: msg})]
end

class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end  

class TransactionKlass
  def initialize(amount, username, time = Time.now)
    @hash = (Digest::SHA2.new << (time.to_s + amount.to_s + username.to_s)).to_s
    @time = time
    @amount = amount
    @username = username
  end

  def time
    @time.to_s
  end

  def hash
    @hash.to_s
  end

  def to_s
    @hash
  end
end
