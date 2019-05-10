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
        IO.inspect(get_commit_count(res))

        json(conn, structure_events(res))
    end
  end


  defp structure_events(events) do
    %{
      commit_count: get_commit_count(events)
    }

  end

  defp need_more_events(events) do
    needs_more = events
    |> List.last
    |> Map.get("created_at")
    |> DateTime.from_iso8601()
    |> elem(1)
    |> DateTime.to_date()
    |> (&Date.diff(DateTime.to_date(DateTime.utc_now()), &1)).()
    IO.inspect(needs_more)
  end

  defp only_last_week_events(events) do
    recent_events = events
    |> Enum.filter(fn x -> time_since_event(x) < 7 end)
  end

  defp time_since_event(event) do
    event
    |> Map.get("created_at")
    |> DateTime.from_iso8601()
    |> elem(1)
    |> DateTime.to_date()
    |> (&Date.diff(DateTime.to_date(DateTime.utc_now()), &1)).()
  end

  defp get_commit_count(events) do
    events
    |> only_last_week_events()
    |> Enum.filter(fn x -> x["type"] === "PushEvent" end)
    |> Enum.reduce(0, fn x, acc -> x["payload"]["size"] + acc end)
  end
end
