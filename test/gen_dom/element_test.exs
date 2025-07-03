defmodule GenDOM.ElementTest do
  use ExUnit.Case, async: true

  alias GenDOM.{
    Element,
    Node
  }
  
  describe "Encoding" do
    test "will inherit from Node and extend" do
      parent = Node.new()
      element = Element.new(
        tag_name: "Text",
        attributes: %{"foo" => "bar"},
        class_list: ~w(a b c),
        text_content: "asdf"
      )

      parent = Element.append_child(parent, element)
      element = Element.get(element)

      encoded_element = Element.encode(element)

      assert encoded_element == %{
        pid: element.pid,
        node_type: 1,
        owner_document: nil,
        parent_element: nil,
        child_nodes: [],
        id: "",
        tag_name: "Text",
        attributes: %{"foo" => "bar"},
        class_list: ["a", "b", "c"],
      }
    end
  end
end
