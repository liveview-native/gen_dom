defmodule GenDOM.Text do
  @derive {Inspect, only: [:whole_text]}

  use GenDOM.Node, [
    node_type: 3,
    assigned_slot: nil,
    whole_text: nil
  ]

  def clone_node(text_pid, deep? \\ false) do
    text = get(text_pid)
    fields = Map.drop(text, [
      :__struct__,
      :pid,
      :receiver,
      :owner_document,
      :parent_element,
      :parent_node,
      :previous_sibling,
      :last_child,
      :first_child,
      :base_node,
      :child_nodes,

      :assigned_slot
    ]) |> Map.to_list()

    new_text = apply(text.__struct__, :new, [fields])

    if deep? do
      Enum.reduce(text.child_nodes, new_text.pid, fn(child_node_pid, new_text_pid) ->
        child_node = GenServer.call(child_node_pid, :get)
        append_child(new_text_pid, clone_node(child_node, deep?))
      end)
    else
      new_text.pid
    end
  end

  def encode(text) do
    Map.merge(super(text), %{
      whole_text: text.whole_text
    })
  end

  def allowed_fields,
    do: super() ++ [:whole_text] 
end
