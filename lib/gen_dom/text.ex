defmodule GenDOM.Text do
  @derive {Inspect, only: [:whole_text]}

  use GenDOM.Node, [
    assigned_slot: nil,
    whole_text: nil
  ]

  def new(opts) when is_list(opts) do
    case start_link(opts) do
      {:ok, pid} -> GenServer.call(pid, :get)
      _other -> {:error, "could not start"}
    end
  end
end
