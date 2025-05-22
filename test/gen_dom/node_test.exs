defmodule GenDOM.NodeTest do
  use ExUnit.Case, async: true

  alias GenDOM.Node

  # Define a test module that inherits from Node for testing purposes
  defmodule TestNode do
    use GenDOM.Node, [
      test_property: "test value"
    ]

    def new(opts) do
      case start_link(opts) do
        {:ok, pid} -> GenServer.call(pid, :get)
        _other -> {:error, "cannot start"}
      end
    end

    # Explicitly implement GenServer callbacks
    def handle_call(:get, _from, node) do
      {:reply, node, node}
    end

    def handle_call({:assign, assigns}, from, node) when is_list(assigns) do
      GenDOM.Node.handle_call({:assign, assigns}, from, node)
    end

    def handle_call({:assign, assigns}, from, node) when is_map(assigns) do
      GenDOM.Node.handle_call({:assign, assigns}, from, node)
    end

    def handle_call({:merge, fields}, from, node) do
      GenDOM.Node.handle_call({:merge, fields}, from, node)
    end

    def handle_call({:put, field, value}, from, node) do
      GenDOM.Node.handle_call({:put, field, value}, from, node)
    end

    def handle_cast({:assign, assigns}, node) when is_list(assigns) do
      GenDOM.Node.handle_cast({:assign, assigns}, node)
    end

    def handle_cast({:assign, assigns}, node) when is_map(assigns) do
      GenDOM.Node.handle_cast({:assign, assigns}, node)
    end

    def handle_cast({:merge, fields}, node) do
      GenDOM.Node.handle_cast({:merge, fields}, node)
    end

    def handle_cast({:put, field, value}, node) do
      GenDOM.Node.handle_cast({:put, field, value}, node)
    end

    def handle_cast({:track, child}, node) do
      GenDOM.Node.handle_cast({:track, child}, node)
    end

    def handle_cast({:untrack, child}, node) do
      GenDOM.Node.handle_cast({:untrack, child}, node)
    end
  end

  describe "Node" do
    test "creating a Node" do
      node = Node.new([])
      assert %Node{} = node
      assert is_atom(node.name)
    end

    test "getting a Node by its name" do
      node = Node.new([])

      same_node = Node.get(node.name)
      assert same_node == node
    end

    test "assigning a value to the assigns in the Node" do
      node = Node.new([])

      Node.assign(node, :test_key, "test_value")
      updated_node = Node.get(node.name)
      assert updated_node.assigns.test_key == "test_value"

      updated_node = Node.assign(node, %{key1: "value1", key2: "value2"})
      assert updated_node.assigns.key1 == "value1"
      assert updated_node.assigns.key2 == "value2"
    end

    test "putting a value in the Node struct" do
      node = Node.new([])

      Node.put(node, :text_content, "Hello, world!")
      updated_node = Node.get(node.name)
      assert updated_node.text_content == "Hello, world!"
    end

    test "merging a map of values into the Node" do
      node = Node.new([])

      Node.merge(node, %{
        node_type: 1,
        text_content: "Merged content"
      })

      updated_node = Node.get(node.name)

      assert updated_node.node_type == 1
      assert updated_node.text_content == "Merged content"
    end

    test "appending a child node" do
      parent = Node.new([])

      child = Node.new([])

      updated_parent = Node.append_child(parent, child)

      assert Enum.member?(updated_parent.child_nodes, child.name)

      updated_child = Node.get(child.name)

      assert Enum.member?(updated_parent.all_child_names, updated_child.name)
      assert updated_child.parent_element == parent.name
    end

    test "appending a child node onto a child will tell all parents" do
      parent = Node.new([])

      child1 = Node.new([])
      child2 = Node.new([])
      child3 = Node.new([])

      child2 = Node.append_child(child2, child3)
      child1 = Node.append_child(child1, child2)
      parent = Node.append_child(parent, child1)

      assert MapSet.member?(parent.all_child_names, child1.name)
      assert MapSet.member?(parent.all_child_names, child2.name)
      assert MapSet.member?(parent.all_child_names, child3.name)

      assert MapSet.member?(child1.all_child_names, child2.name)
      assert MapSet.member?(child1.all_child_names, child3.name)

      assert MapSet.member?(child2.all_child_names, child3.name)

      child4 = Node.new([])
      child3 = Node.append_child(child3, child4)

      child2 = Node.get(child2.name)
      child1 = Node.get(child1.name)
      parent = Node.get(parent.name)

      assert MapSet.member?(child3.all_child_names, child4.name)
      assert MapSet.member?(child2.all_child_names, child4.name)
      assert MapSet.member?(child1.all_child_names, child4.name)
      assert MapSet.member?(parent.all_child_names, child4.name)
    end

    test "inserting a child node before another child" do
      parent = Node.new([])

      first_child = Node.new([])

      parent_with_first = Node.append_child(parent, first_child)

      second_child = Node.new([])

      updated_parent = Node.insert_before(parent_with_first, second_child, first_child)

      assert Enum.member?(updated_parent.child_nodes, first_child.name)
      assert Enum.member?(updated_parent.child_nodes, second_child.name)

      first_index = Enum.find_index(updated_parent.child_nodes, fn child -> child == first_child.name end)
      second_index = Enum.find_index(updated_parent.child_nodes, fn child -> child == second_child.name end)
      assert second_index < first_index
    end

    test "removing a child node" do
      parent = Node.new([])

      child = Node.new([])

      parent_with_child = Node.append_child(parent, child)
      assert Enum.member?(parent_with_child.child_nodes, child.name)

      # Remove child
      updated_parent = Node.remove_child(parent_with_child, child)
      refute Enum.member?(updated_parent.child_nodes, child.name)
    end

    test "replacing a child node" do
      parent = Node.new([])

      old_child = Node.new([])

      parent_with_old = Node.append_child(parent, old_child)

      new_child = Node.new([])

      updated_parent = Node.replace_child(parent_with_old, new_child, old_child)

      refute Enum.member?(updated_parent.child_nodes, old_child.name)

      assert Enum.member?(updated_parent.child_nodes, new_child.name)
    end
  end

  describe "Node inheritance" do
    test "creating a TestNode" do
      node = TestNode.new([])
      assert %TestNode{} = node
      assert is_atom(node.name)
      assert MapSet.new([]) == node.all_child_names
      assert "test value" == node.test_property
    end

    test "child management with inherited node" do
      parent = TestNode.new([])
      child1 = TestNode.new([])
      child2 = TestNode.new([])

      GenServer.cast(parent.name, {:track, child1})
      updated_parent = GenServer.call(parent.name, :get)
      assert MapSet.member?(updated_parent.all_child_names, child1.name)

      GenServer.cast(parent.name, {:track, child2})
      updated_parent = GenServer.call(parent.name, :get)
      assert MapSet.member?(updated_parent.all_child_names, child2.name)
      assert MapSet.size(updated_parent.all_child_names) == 2

      GenServer.cast(parent.name, {:untrack, child1})
      updated_parent = GenServer.call(parent.name, :get)
      refute MapSet.member?(updated_parent.all_child_names, child1.name)
      assert MapSet.member?(updated_parent.all_child_names, child2.name)
      assert MapSet.size(updated_parent.all_child_names) == 1

      GenServer.cast(parent.name, {:untrack, child2})
      updated_parent = GenServer.call(parent.name, :get)
      refute MapSet.member?(updated_parent.all_child_names, child2.name)
      assert MapSet.size(updated_parent.all_child_names) == 0
    end

    test "untracking a non-existent child" do
      parent = TestNode.new([])
      child = TestNode.new([])

      GenServer.cast(parent.name, {:untrack, child})
      updated_parent = GenServer.call(parent.name, :get)
      assert MapSet.size(updated_parent.all_child_names) == 0
    end

    test "demonitor handles non-existent child references" do
      parent = TestNode.new([])
      child = TestNode.new([])

      GenServer.cast(parent.name, {:track, child})
      updated_parent = GenServer.call(parent.name, :get)
      assert MapSet.member?(updated_parent.all_child_names, child.name)

      GenServer.cast(parent.name, {:untrack, child})
      updated_parent = GenServer.call(parent.name, :get)
      refute MapSet.member?(updated_parent.all_child_names, child.name)

      GenServer.cast(parent.name, {:untrack, child})
      final_parent = GenServer.call(parent.name, :get)
      refute MapSet.member?(final_parent.all_child_names, child.name)
    end
  end
end
