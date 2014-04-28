# Copyleft Kaley Halloran 2014 <kaleyhalloran@gmail.com>
#

require 'sinatra'
require_relative 'models'
require_relative 'helpers'
require 'time'

I18n.enforce_available_locales = false

# Register
post '/register' do
  @username = params[:username]
  @password = params[:password]

  # Do we have a username and password in params?
  if not @username or not @password
    # error
    return json_error("Username or password not provided")
  end

  # Check for username availability
  if User.find_by_username(@username)
    # error
    return json_error("Username #{@username} has already been taken")
  end

  # Register user
  salt = get_rand
  if User.create(username: @username, 
    phash: User.hash_password(@password, salt), 
    salt: salt,
    balance: 0) then
    return 200
  else
    # it failed
    return json_error("Failed to create user")
  end
end

# Sign in
post '/login' do
  @username = params[:username]
  @password = params[:password]

  # Do we have a username and password in params?
  if not @username or not @password
    # error
    return json_error("Username or password not provided")
  end

  # Check password against username
  return to_json({token: User.login(@username, @password)})
end

# Authenticate user
before %r{transaction|balance} do
  # Check token is valid
  @token = params[:token]

  if (not @token)
    return json_error("Token needed")
  end

  @user = User.find_by_token(@token)

  if (not @user)
    return json_error("Invalid token")
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
    return json_error("Parameter not provided")
  end

  @created = Time.parse(@created)

  # Check for a conflicting hash
  if Transaction.find_by_thash(@thash)
    # conflicting hash error
    return json_error("Conflicting transaction hash")
  end

  # Save transaction
  if (t = Transaction.create(amount: @amount,
    user: @user,
    thash: @thash,
    created: @created))

    # Update balance
    if not (@amount.numeric?)
      return json_error("Amount not numeric")
    end

    @user.balance += t.amount
    if not @user.save
      return json_error("Error saving balance")
    else
      return 200
    end
  else
    return json_error("Transaction could not be saved")
  end
end

# Get balance
get '/balance' do

  # Return balance
  return to_json({balance: @user.balance})
end
