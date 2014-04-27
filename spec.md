# Registering

POST /register?username=desired_username&password=desired_password

Returns a 500 on error, and a 200 on success.  Error message is returned in JSON ({error: msg}).

# Logging in

POST /login?username=username&password=password

Returns a 500 on error, and a 200 on success.  Token is returned as JSON ({token: string}).

This token is required as a parameter for all other requests.

# Getting a balance

GET /balance?token=token

Returns the balance ({balance: number}).

# Transactions

Transactions each have a unique ID that is determined by hashing some data together.
Use SHA2, with a 256-bit length for the hash.  The hash is determined by the current time (Ruby's Time.now.to_s),
plus the transaction amount, plus the username.  i.e. sha2(Time.now + amount + username).

All of this information is sent to the server in the following way:

POST /transaction?created=time&amount=number&hash=id&token=token

Returns a 500 on error, and a 200 on success.
