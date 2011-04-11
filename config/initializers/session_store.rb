# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simple_test_plans_session',
  :secret      => '9ecf3bc6be5b2d8d0837f2426ce20a9522fe5254045afd224a6bdc8126276d1f5bb6d69f867ef19e8aa1a826497e8a3f930e763e32ed14338cf55bb006a41776'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
