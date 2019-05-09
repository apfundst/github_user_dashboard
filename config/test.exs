use Mix.Config

# Configure your database
config :github_user_dashboard, GithubUserDashboard.Repo,
  username: "postgres",
  password: "postgres",
  database: "github_user_dashboard_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :github_user_dashboard, GithubUserDashboardWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
