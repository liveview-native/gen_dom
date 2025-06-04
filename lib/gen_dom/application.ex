defmodule GenDOM.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: :pg,
        start: {:pg, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
