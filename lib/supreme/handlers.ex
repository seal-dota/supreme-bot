defmodule Supreme.Handlers do
  @moduledoc """
  An all so original echo and ping bot!
  Type "!example:echo hello!" or "!example:ping" to get a reply back.
  """
  require Logger
  require Tentacat

  alias DiscordEx.Client.Helpers.MessageHelper
  alias DiscordEx.RestClient.Resources.Channel

  # Message Handler
  def handle_event({:message_create, payload}, state) do
    spawn fn ->
      _command_parser(payload, state)
    end
    {:ok, state}
  end

  # Fallback Handler
  def handle_event({event, _payload}, state) do
    Logger.info "Received Event: #{event}"
    {:ok, state}
  end

  # Select command to execute based off message payload
  defp _command_parser(payload, state) do
    if payload.data["author"]["bot"] do
      Logger.info "ignoring bot message"
    else
      case MessageHelper.msg_command_parse(payload, ".") do
        {nil, msg} ->
          Logger.info("do nothing for message #{msg}")
        {cmd, msg} ->
          _execute_command({cmd, msg}, payload, state)
      end
    end
  end

  defp _execute_command({"issue", message}, payload, state) do
    split_me = Application.get_env(:supreme, :whitelist)
    whitelist = String.split(split_me, ",")
    usertag = payload.data["author"]["username"] <> "#" <> payload.data["author"]["discriminator"]
    if Enum.member?(whitelist, usertag) do
      github_token = Application.get_env(:supreme, :github_token)
      org = Application.get_env(:supreme, :github_org)
      [repo, title | tail] = String.split(message, " => ")
      body = List.first(tail)
      client = Tentacat.Client.new(%{access_token: github_token})
      {code, issue} = Tentacat.Issues.create(org, repo, %{"title" => title, "body" => body}, client)
      {maintainer_id, _} = Integer.parse(Application.get_env(:supreme, :maintainer_discord_id))
      content = case code do
        201 -> "Issue created: <#{issue["html_url"]}>"
        _ -> "Error probably occurred, please check logs <@#{maintainer_id}>"
      end
      Channel.send_message(state[:rest_client], payload.data["channel_id"], %{content: content})
    end
  end
end
