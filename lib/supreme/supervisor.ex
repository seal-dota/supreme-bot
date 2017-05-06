defmodule Supreme.Supervisor do
  use Supervisor

  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    discord_token = Application.get_env(:supreme, :discord_token)
    children = [
      worker(DiscordEx.Client, [%{token: discord_token, handler: Supreme.Handlers}]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
