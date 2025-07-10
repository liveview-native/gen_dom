defmodule GenDOM.NodeTest do
  use ExUnit.Case, async: true

  alias GenDOM.{
    Element,
    Node
  }

  # Define a test module that inherits from Node for testing purposes
  defmodule TestNode do
    use GenDOM.Node, [
      test_property: "test value"
    ]

    def encode(test_node) do
      Map.merge(super(test_node), %{
        test_property: test_node.test_property
      })
    end
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

      Node.assign(node.pid, :test_key, "test_value")
      updated_node = Node.get(node.pid)
      assert updated_node.assigns.test_key == "test_value"

      updated_node_pid = Node.assign(node.pid, %{key1: "value1", key2: "value2"})
      updated_node = Node.get(updated_node_pid)
      assert updated_node.assigns.key1 == "value1"
      assert updated_node.assigns.key2 == "value2"
    end

    test "putting a value in the Node struct" do
      node = Node.new([])

      Node.put(node.pid, :text_content, "Hello, world!")
      updated_node = Node.get(node.pid)
      assert updated_node.text_content == "Hello, world!"
    end

    test "merging a map of values into the Node" do
      node = Node.new([])

      Node.merge(node.pid, %{
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

      Node.append_child(parent.pid, child.pid)
      updated_parent = Node.get(parent.pid)

      assert Enum.member?(updated_parent.child_nodes, child.pid)

      updated_child = Node.get(child.pid)

      assert Enum.member?(:pg.get_members(updated_parent.pid), updated_child.pid)
      assert updated_child.parent_node == parent.pid
    end

    test "appending a child node onto a child will tell all parents" do
      parent = Node.new([])
      child_1 = Element.new([])
      child_2 = Element.new([])
      child_3 = Element.new([])

      Node.append_child(child_2.pid, child_3.pid)

      Node.append_child(child_1.pid, child_2.pid)
      Node.append_child(parent.pid, child_1.pid, receiver: self())

      assert_received {:append_child, parent_pid, %{
        pid: child_1_pid,
        child_nodes: [
          %{
            pid: child_2_pid,
            child_nodes: [%{
              pid: child_3_pid,
              child_nodes: [],
              owner_document: nil,
              parent_element: child_2_pid
            }],
            owner_document: nil,
            parent_element: child_1_pid
          }
        ],
        owner_document: nil,
        parent_element: nil 
      }}

      assert parent_pid == parent.pid
      assert child_1_pid == child_1.pid
      assert child_2_pid == child_2.pid
      assert child_3_pid == child_3.pid

      assert Enum.member?(:pg.get_members(parent.pid), child_1.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child_2.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child_3.pid)

      assert Enum.member?(:pg.get_members(child_1.pid), child_2.pid)
      assert Enum.member?(:pg.get_members(child_1.pid), child_3.pid)

      assert Enum.member?(:pg.get_members(child_2.pid), child_3.pid)

      child_4 = Node.new([])

      Node.append_child(child_3.pid, child_4.pid, receiver: self())

      assert_received {:append_child, ^child_3_pid, %{
        pid: child_4_pid,
        child_nodes: [],
        parent_element: ^child_3_pid,
        owner_document: nil
      }}

      assert child_4_pid == child_4.pid

      :timer.sleep(1)

      assert Enum.member?(:pg.get_members(child_3.pid), child_4.pid)
      assert Enum.member?(:pg.get_members(child_2.pid), child_4.pid)
      assert Enum.member?(:pg.get_members(child_1.pid), child_4.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child_4.pid)
    end

    test "inserting a child node before another child" do
      parent = Node.new([])

      child_1 = Node.new([])

      Node.append_child(parent.pid, child_1)

      child_2 = Node.new([])

      Node.insert_before(parent.pid, child_2.pid, child_1.pid, receiver: self())

      parent = Node.get(parent.pid)

      assert_received {:insert_before, parent_pid, %{
        pid: child_2_pid,
        child_nodes: [],
        owner_document: nil,
        parent_element: nil
      }, child_1_pid}

      assert parent_pid == parent.pid
      assert child_1_pid == child_1.pid
      assert child_2_pid == child_2.pid

      assert Enum.member?(parent.child_nodes, child_1.pid)
      assert Enum.member?(parent.child_nodes, child_2.pid)
      assert Enum.member?(:pg.get_members(parent.pid), child_2.pid)

      first_index = Enum.find_index(parent.child_nodes, fn child -> child == child_1.pid end)
      second_index = Enum.find_index(parent.child_nodes, fn child -> child == child_2.pid end)
      assert second_index < first_index
    end

    test "removing a child node" do
      parent = Node.new([])

      child = Node.new([])

      Node.append_child(parent.pid, child)
      parent = Node.get(parent.pid)
      assert Enum.member?(parent.child_nodes, child.pid)

      # Remove child
      Node.remove_child(parent.pid, child, receiver: self())
      parent = Node.get(parent.pid)
      assert_received {:remove_child, parent_pid, child_pid}

      assert parent_pid == parent.pid
      assert child_pid == child.pid

      refute Enum.member?(parent.child_nodes, child.pid)
      refute Enum.member?(:pg.get_members(parent.pid), child.pid)
    end

    test "removing a child node from a child will tell all parents" do
      parent = Node.new([])

      child_1 = Node.new([])
      child_2 = Node.new([])

      Node.append_child(child_1.pid, child_2.pid)
      child_1 = Node.get(child_1.pid)

      Node.append_child(parent.pid, child_1.pid)
      parent = Node.get(parent.pid)

      Node.remove_child(child_1.pid, child_2.pid)
      child_1 = Node.get(child_1.pid)

      refute Enum.member?(:pg.get_members(child_1.pid), child_2.pid)
      refute Enum.member?(:pg.get_members(parent.pid), child_2.pid)
    end

    test "replacing a child node" do
      parent = Node.new([])

      child_1 = Element.new([])

      old_child = Node.new([])

      Node.append_child(parent.pid, child_1.pid)
      parent = Node.get(parent.pid)
      Element.append_child(child_1.pid, old_child.pid)
      child_1 = Node.get(child_1.pid)

      new_child = Node.new([])

      Node.replace_child(child_1.pid, new_child.pid, old_child.pid, receiver: self())
      child_1 = Node.get(child_1.pid)

      assert_received {:replace_child, child_1_pid, %{
        pid: new_child_pid,
        child_nodes: [],
        owner_document: nil,
        parent_element: child_1_pid 
      }, old_child_pid}

      assert child_1_pid == child_1.pid
      assert new_child_pid == new_child.pid
      assert old_child_pid == old_child.pid

      refute Enum.member?(child_1.child_nodes, old_child.pid)
      assert Enum.member?(child_1.child_nodes, new_child.pid)

      refute Enum.member?(:pg.get_members(child_1.pid), old_child.pid)
      refute Enum.member?(:pg.get_members(parent.pid), old_child.pid)

      assert Enum.member?(:pg.get_members(child_1.pid), new_child.pid)
      assert Enum.member?(:pg.get_members(parent.pid), new_child.pid)
    end
  end

  describe "encoding" do
    test "encoding from pid will fetch the state and encode" do
      node = Node.new([])

      encoded_node = Node.encode(node.pid)

      assert encoded_node == %{
        pid: node.pid,
        node_type: 0,
        owner_document: nil,
        parent_element: nil,
        child_nodes: []
      }
    end

    test "will encode from struct" do
      node = Node.new([])

      encoded_node = Node.encode(node)

      assert encoded_node == %{
        pid: node.pid,
        node_type: 0,
        owner_document: nil,
        parent_element: nil,
        child_nodes: []
      }
    end

    test "will recursively encode children" do
      node = Node.new([])
      child = TestNode.new(test_property: "other")

      Node.append_child(node.pid, child)

      node = Node.get(node.pid)

      encoded_node = Node.encode(node)

      assert encoded_node == %{
        pid: node.pid,
        node_type: 0,
        owner_document: nil,
        parent_element: nil,
        child_nodes: [
          %{
            pid: child.pid,
            node_type: 0,
            owner_document: nil,
            parent_element: nil,
            test_property: "other",
            child_nodes: []
          }
        ]
      }
    end
  end
end
