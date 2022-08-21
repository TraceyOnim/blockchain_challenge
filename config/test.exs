import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :trans_chain, TransChainWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nRGAazqxeo0eynAR7UZlBwQU5dGcApbwea6KrWFH5nlrnENy9LiTY4QxxdzXMRLf",
  server: false

# In test we don't send emails.
config :trans_chain, TransChain.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :trans_chain, :http_client, TransChain.HttpClientMock
