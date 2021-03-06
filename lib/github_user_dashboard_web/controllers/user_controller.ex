defmodule GithubUserDashboardWeb.UserController do
  use GithubUserDashboardWeb, :controller

  def index(conn, _params) do
    # get session
    access_token = get_session(conn, :access_token)
    IO.inspect(access_token)
    headers = [authorization: "token " <> access_token]

    case HTTPoison.get("https://api.github.com/user", headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        res = Poison.decode!(body)
        IO.inspect(res)

        put_session(conn, :username, res["login"])
        |> render("index.html", user: res)
    end
  end
end
