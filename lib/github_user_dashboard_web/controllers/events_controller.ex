defmodule GithubUserDashboardWeb.EventsController do
  use GithubUserDashboardWeb, :controller

  def index(conn, _params) do
    # get session
    access_token = get_session(conn, :access_token)
    user_name = get_session(conn, :username)
    IO.inspect(user_name)

    headers = [authorization: "token " <> access_token]

    case HTTPoison.get("https://api.github.com/users/#{user_name}/events", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        res = Poison.decode!(body)
        IO.inspect(res)
        json(conn, res)
    end
  end
end
