defmodule GithubUserDashboard.Repo do
  use Ecto.Repo,
    otp_app: :github_user_dashboard,
    adapter: Ecto.Adapters.Postgres
end
