defmodule GithubUserDashboardWeb.SessionController do
  use GithubUserDashboardWeb, :controller

  def index(conn, params = %{"code" => code}) do
    case authenticate(conn) do
      nil ->
        clientID = GithubUserDashboard.Config.client_id()
        clientSecret = GithubUserDashboard.Config.client_secret()
        IO.inspect(clientID)

        json =
          Poison.encode!(%{
            client_id: clientID,
            client_secret: clientSecret,
            code: code,
            redirect_uri: "https://drew-github-dahsboard.ngrok.io/callback"
          })

        case HTTPoison.post("https://github.com/login/oauth/access_token", json, [
               {"Content-Type", "application/json"}
             ]) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            IO.inspect(body)
            res = URI.decode_query(body)
            IO.inspect(res)
            IO.inspect(res["access_token"])

            put_session(conn, :access_token, res["access_token"])
            |> redirect(to: "/user")
        end

      _ ->
        redirect(conn, to: "/user")
    end
  end

  def index(conn, _params) do
    case authenticate(conn) do
      nil ->
        redirect(conn, to: "/")

      _ ->
        redirect(conn, to: "/user")
    end
  end

  def authenticate(conn) do
    get_session(conn, :access_token)
  end
end
