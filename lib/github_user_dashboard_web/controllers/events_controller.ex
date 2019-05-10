defmodule GithubUserDashboardWeb.EventsController do
  use GithubUserDashboardWeb, :controller

  def index(conn, _params) do
    # get session
    access_token = get_session(conn, :access_token)
    user_name = get_session(conn, :username)
    IO.inspect(user_name)

    headers = [authorization: "token " <> access_token]

    case get_events(user_name, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        res = Poison.decode!(body)
        # require IEx
        # IEx.pry
        all_events = need_more_events(res, user_name, headers, 1)
        json(conn, structure_events(all_events))
    end
  end

  defp get_events(user_name, headers) do
    HTTPoison.get("https://api.github.com/users/#{user_name}/events", headers)
  end

  defp get_events(user_name, headers, page) do
    HTTPoison.get("https://api.github.com/users/#{user_name}/events?page=#{page}", headers)
  end

  defp structure_events(events) do
    %{
      commit_count: get_commit_count(events),
      pr_data: get_pr_data(events)
    }
  end

  defp need_more_events(events, user_name, headers, page) do
    needs_more =
      events
      |> only_last_week_events()
      |> length

    cond do
      needs_more < 30 ->
        events
      needs_more == length(events) ->
        case get_events(user_name, headers, page + 1) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            res = Poison.decode!(body)
            need_more_events(Enum.concat(events, res), user_name, headers, page + 1)
        end
      needs_more < length(events) ->
        events
    end
  end

  defp only_last_week_events(events) do
    events
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

  defp get_pr_data(events) do
    pr_events =
      events
      |> only_last_week_events()
      |> Enum.filter(fn x -> x["type"] === "PullRequestEvent" end)

    %{
      prs_opened: get_pr_opened_count(pr_events),
      prs_merged: get_pr_merged_count(pr_events),
      additions: get_additions(pr_events),
      deletions: get_deletions(pr_events)
    }
  end

  defp get_pr_opened_count(pr_events) do
    pr_events
    |> Enum.filter(fn x -> x["payload"]["action"] === "opened" end)
    |> length()
  end

  defp get_merged_prs(pr_events) do
    pr_events
    |> Enum.filter(fn x -> x["payload"]["action"] === "closed" end)
    |> Enum.filter(fn x -> x["payload"]["pull_request"]["merged_at"] != nil end)
  end

  defp get_pr_merged_count(pr_events) do
    get_merged_prs(pr_events)
    |> length()
  end

  defp get_additions(pr_events) do
    get_merged_prs(pr_events)
    |> Enum.reduce(0, fn x, acc -> x["payload"]["pull_request"]["additions"] + acc end)
  end

  defp get_deletions(pr_events) do
    get_merged_prs(pr_events)
    |> Enum.reduce(0, fn x, acc -> x["payload"]["pull_request"]["deletions"] + acc end)
  end

  def get_header(headers, key) do
    headers
    |> Enum.filter(fn {k, _} -> k == key end)
    |> hd
    |> elem(1)
  end
end
