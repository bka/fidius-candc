# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cuc-server_session',
  :secret      => 'd146d56da0e9d5e2d716b4b886cd3efdebee13d29bb5d11c1bb2ac08609511368538d1afb2d1ec1b2afea1d775d60b5fa3cb07cb6a7fcebc9cc85c3b5a45028d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
