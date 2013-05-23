# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
MediaBackend::Application.config.secret_key_base = 'e1525dd14323360b6c6c0c5da59a1ae88b16c604e97a0e8ca245ddf1460107f369ed1989ea262fb05884069772224252659755a42fd54ff8055ea41865f89a28'
