defmodule GenDOM.NodeTest do
  use ExUnit.Case, async: true

  alias GenDOM.Node

  # Define a test module that inherits from Node for testing purposes
  defmodule TestNode do
    use GenDOM.Node, [
      test_property: "test value"
    ]
  end

  describe "Node" do
    test "creating a Node" do
      node = Node.new([])
      assert %Node{} = node
      assert is_pid(node.pid)
    end

    test "getting a Node by its name" do
      node = Node.new([])

      same_node = Node.get(node.pid)
      assert same_node == node
    end

    test "assigning a value to the assigns in the Node" do
      node = Node.new([])

      Node.assign(node, :test_key, "test_value")
      updated_node = Node.get(node.pid)
      assert updated_node.assigns.test_key == "test_value"

      updated_node = Node.assign(node, %{key1: "value1", key2: "value2"})
      assert updated_node.assigns.key1 == "value1"
      assert updated_node.assigns.key2 == "value2"
    end

    test "putting a value in the Node struct" do
      node = Node.new([])

      Node.put(node, :text_content, "Hello, world!")
      updated_node = Node.get(node.pid)
      assert updated_node.text_content == "Hello, world!"
    end

    test "merging a map of values into the Node" do
      node = Node.new([])

      Node.merge(node, %{
        node_type: 1,
        text_content: "Merged content"
      })

      updated_node = Node.get(node.pid)

      assert updated_node.node_type == 1
      assert updated_node.text_content == "Merged content"
    end

    test "appending a child node" do
      parent = Node.new([])

      child = Node.new([])

      updated_parent = Node.append_child(parent, child)

      assert Enum.member?(updated_parent.child_nodes, child.pid)

      updated_child = Node.get(child.pid)

      assert Enum.member?(:pg.get_members(updated_parent.pid), updated_child.pid)
      assert updated_child.parent_element == parent.pid
    end

    test "appending a child node onto a child will tell all parents" do
      parent = Node.new([])

      child1 = Node.new([])
      child2 = Node.new([])
      child3 = Node.new([])

      child2 = Node.append_child(child2, child3)
      child1 = Node.append_child(child1, child2)
      parent = Node.append_child(parent, child1)

      assert Enum.member?(:pg.get_members(parent.pid), child1.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child2.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child3.pid)

      assert Enum.member?(:pg.get_members(child1.pid), child2.pid)
      assert Enum.member?(:pg.get_members(child1.pid), child3.pid)

      assert Enum.member?(:pg.get_members(child2.pid), child3.pid)

      child4 = Node.new([])
      child3 = Node.append_child(child3, child4)

      child2 = Node.get(child2.pid)
      child1 = Node.get(child1.pid)
      parent = Node.get(parent.pid)

      assert Enum.member?(:pg.get_members(child3.pid), child4.pid)
      assert Enum.member?(:pg.get_members(child2.pid), child4.pid)
      assert Enum.member?(:pg.get_members(child1.pid), child4.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child4.pid)
    end

    test "inserting a child node before another child" do
      parent = Node.new([])

      first_child = Node.new([])

      parent_with_first = Node.append_child(parent, first_child)

      second_child = Node.new([])

      updated_parent = Node.insert_before(parent_with_first, second_child, first_child)

      assert Enum.member?(updated_parent.child_nodes, first_child.pid)
      assert Enum.member?(updated_parent.child_nodes, second_child.pid)
      assert Enum.member?(:pg.get_members(updated_parent.pid), second_child.pid)

      first_index = Enum.find_index(updated_parent.child_nodes, fn child -> child == first_child.pid end)
      second_index = Enum.find_index(updated_parent.child_nodes, fn child -> child == second_child.pid end)
      assert second_index < first_index
    end

    test "removing a child node" do
      parent = Node.new([])

      child = Node.new([])

      parent = Node.append_child(parent, child)
      assert Enum.member?(parent.child_nodes, child.pid)

      # Remove child
      parent = Node.remove_child(parent, child)
      refute Enum.member?(parent.child_nodes, child.pid)
      refute Enum.member?(:pg.get_members(parent.pid), child.pid)
    end

    test "removing a child node from a child will tell all parents" do
      parent = Node.new([])

      child1 = Node.new([])
      child2 = Node.new([])

      child1 = Node.append_child(child1, child2)
      parent = Node.append_child(parent, child1)

      child1 = Node.remove_child(child1, child2)

      :timer.sleep(1)

      refute Enum.member?(:pg.get_members(child1.pid), child2.pid)
      refute Enum.member?(:pg.get_members(parent.pid), child2.pid)
    end

    test "replacing a child node" do
      parent = Node.new([])

      child1 = Node.new([])

      old_child = Node.new([])

      parent = Node.append_child(parent, child1)
      child1 = Node.append_child(child1, old_child)

      new_child = Node.new([])

      child1 = Node.replace_child(child1, new_child, old_child)

      :timer.sleep(1)

      refute Enum.member?(child1.child_nodes, old_child.pid)
      assert Enum.member?(child1.child_nodes, new_child.pid)

      refute Enum.member?(:pg.get_members(child1.pid), old_child.pid)
      refute Enum.member?(:pg.get_members(parent.pid), old_child.pid)

      assert Enum.member?(:pg.get_members(child1.pid), new_child.pid)
      assert Enum.member?(:pg.get_members(parent.pid), new_child.pid)
    end
  end
end
