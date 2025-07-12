defmodule GenDOM.DocumentTest do
  use ExUnit.Case, async: true

  alias GenDOM.{Document, Element, Node}

  describe "Encoding" do
    test "will inherit form Node and extend" do
      parent = Node.new()
      document = Document.new()

      Node.append_child(parent.pid, document.pid)
      document = Document.get(document.pid)

      encoded_document = Document.encode(document)

      assert encoded_document == %{
        pid: document.pid,
        node_type: 10,
        owner_document: nil,
        parent_element: nil,
        child_nodes: [],
        style_sheets: [],
        title: nil,
        url: nil,
        body: nil,
        head: nil
      }
    end
  end
end
