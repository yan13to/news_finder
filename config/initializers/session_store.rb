# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bupan_session',
  :secret      => '311af9b14ce8e2f7d15e7ef51c3f3e2d354a788b2b275f203bddcca3634d81afcbe0d488d4b8217c879589e014c8ad18056421b5bd7fb4046f8b474e2f9943ea'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
