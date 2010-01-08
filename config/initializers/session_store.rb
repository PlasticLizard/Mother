# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Mother_session',
  :secret      => '8ccc1704e51892daf13ff43448f72598ecf2560357f3d66f33f0f38970c6d67a929af8e47aa64cd54b2e2eb726e3cf85ca7583d52233cf5739c0b83593527b1d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
