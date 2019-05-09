defmodule GithubUserDashboardWeb.PageController do
  use GithubUserDashboardWeb, :controller

  def index(conn, _params) do
    case get_session(conn, :access_token) do
      nil ->
        render(conn, "index.html")
      _ ->
        redirect(conn, to: "/user")
    end
  end
end
