defmodule Supreme do
  use Application

  require Logger

  def start(_type, _args) do
    Supreme.Supervisor.start_link
  end
end
