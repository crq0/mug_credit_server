# Copyleft Kaley Halloran 2014 <kaleyhalloran@gmail.com>
#

require 'sinatra'
require_relative 'models'
require_relative 'helpers'
require 'time'

get '/' do
  return to_json({:text => "Hello world"})
end

# Register
post '/register' do
  @username = params[:username]
  @password = params[:password]

  # Do we have a username and password in params?
  if not @username or not @password
    # error
    return error("Username or password not provided")
  end

  # Check for username availability
  if User.find_by_username(@username)
    # error
    return error("Username #{@username} has already been taken")
  end

  # Register user
  salt = get_rand
  puts salt
  if User.create(username: @username, 
    phash: User.hash_password(@password, salt), 
    salt: salt,
    balance: 0) then
    return 200
  else
    # it failed
    return error("Failed to create user")
  end
end

# Sign in
post '/login' do
  @username = params[:username]
  @password = params[:password]

  # Do we have a username and password in params?
  if not @username or not @password
    # error
    return error("Username or password not provided")
  end

  # Check password against username
  return to_json({token: User.login(@username, @password)})
end

# Authenticate user
before %r{transaction|balance} do
  # Check token is valid
  @token = params[:token]

  if (not @token)
    return error("Token needed")
  end

  @user = User.find_by_token(@token)

  if (not @user)
    return error("Invalid token")
  end

  # Successful login!
end

# Post transaction
post '/transaction' do
  # Do we have required paramters?
  @amount = params[:amount]
  @created = params[:created]
  @thash = params[:hash]

  puts @amount, @created, @hash

  if (not @amount) or (not @created) or (not @thash)
    return error("Parameter not provided")
  end

  @created = Time.parse(@created)

  # Check for a conflicting hash
  if Transaction.find_by_thash(@thash)
    # conflicting hash error
    return error("Conflicting transaction hash")
  end

  # Save transaction
  if Transaction.create(amount: @amount,
    user: @user,
    thash: @thash,
    created: @created)

    # Update balance
    if not (@amount.numeric?)
      return error("Amount not numeric")
    end

    @user.balance + @amount.to_f
    if not @user.save
      return error("Error saving balance")
    else
      return 200
    end
  else
    return error("Transaction could not be saved")
  end
end

# Get balance
get '/balance' do
  # Do we have required parameters?

  # Return balance
  return to_json({balance: @user.balance})
end
