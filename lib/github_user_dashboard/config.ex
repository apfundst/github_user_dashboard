defmodule GithubUserDashboard.Config do
  def client_id() do
    Application.get_env(:github_user_dashboard, :client_id)
  end

  def client_secret() do
    Application.get_env(:github_user_dashboard, :client_secret)
  end
end
