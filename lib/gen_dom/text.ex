defmodule GenDOM.Text do
  @derive {Inspect, only: [:whole_text]}

  use GenDOM.Node, [
    node_type: 3,
    assigned_slot: nil,
    whole_text: nil
  ]

  def encode(text) do
    Map.merge(super(text), %{
      whole_text: text.whole_text
    })
  end

  def allowed_fields,
    do: super() ++ [:whole_text] 
end
