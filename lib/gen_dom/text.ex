defmodule GenDOM.Text do
  @derive {Inspect, only: [:whole_text]}

  use GenDOM.Node, [
    node_type: 3,
    assigned_slot: nil,
    whole_text: nil
  ]

  def clone_node(node, deep? \\ false) do
    fields = Map.drop(node, [
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

    new_node = apply(node.__struct__, :new, [fields])

    if deep? do
      Enum.reduce(node.child_nodes, new_node, fn(child_node_pid, new_node) ->
        child_node = GenServer.call(child_node_pid, :get)
        append_child(new_node, clone_node(child_node, deep?))
      end)
    else
      new_node
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
