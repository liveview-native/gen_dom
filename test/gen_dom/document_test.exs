defmodule GenDOM.DocumentTest do
  use ExUnit.Case, async: true

  alias GenDOM.{Document, Element, Node}

  describe "Encoding" do
    test "will inherit form Node and extend" do
      parent = Node.new()
      document = Document.new()

      parent = Node.append_child(parent, document)
      document = Document.get(document)

      encoded_document = Document.encode(document)

      assert encoded_document == %{
        pid: document.pid,
        node_type: 10,
        owner_document: nil,
        parent_element: parent.pid,
        child_nodes: [],
        style_sheets: [],
        title: nil,
        url: nil,
        body: nil,
        head: nil
      }
    end
  end

  describe "query_selector/2" do
    test "finds the first element that matches a tag selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")
      p = Element.new(tag_name: "p")

      # Add elements to the document
      document = Node.append_child(document, div)
      _div = Node.append_child(div, p)

      # Test query_selector with tag name
      assert {:ok, matched_element} = Document.query_selector(document, "div")
      assert matched_element.tag_name == "div"

      assert {:ok, matched_element} = Document.query_selector(document, "p")
      assert matched_element.tag_name == "p"
    end

    test "finds the first element that matches an ID selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div", id: "main")
      p = Element.new(tag_name: "p", id: "content")

      # Add elements to the document
      document = Node.append_child(document, div)
      _div = Node.append_child(div, p)

      # Test query_selector with ID
      assert {:ok, matched_element} = Document.query_selector(document, "#main")
      assert matched_element.id == "main"

      assert {:ok, matched_element} = Document.query_selector(document, "#content")
      assert matched_element.id == "content"
    end

    test "finds the first element that matches a class selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div", class_list: ["container"])
      p = Element.new(tag_name: "p", class_list: ["text", "highlight"])

      # Add elements to the document
      document = Node.append_child(document, div)
      _div = Node.append_child(div, p)

      # Test query_selector with class
      assert {:ok, matched_element} = Document.query_selector(document, ".container")
      assert "container" in matched_element.class_list

      assert {:ok, matched_element} = Document.query_selector(document, ".highlight")
      assert "highlight" in matched_element.class_list
    end

    test "returns error when no element matches the selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")

      # Add elements to the document
      document = Node.append_child(document, div)

      # Test query_selector with non-existent element
      assert {:error, :not_found} = Document.query_selector(document, "span")
      assert {:error, :not_found} = Document.query_selector(document, "#nonexistent")
      assert {:error, :not_found} = Document.query_selector(document, ".missing")
    end
  end

  describe "query_selector_all/2" do
    test "finds all elements that match a tag selector" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div")
      div2 = Element.new(tag_name: "div")
      p = Element.new(tag_name: "p")

      # Add elements to the document
      document = Node.append_child(document, div1)
      document = Node.append_child(document, div2)
      _div1 = Node.append_child(div1, p)

      # Test query_selector_all with tag name
      assert {:ok, matched_elements} = Document.query_selector_all(document, "div")
      assert length(matched_elements) == 2
      assert Enum.all?(matched_elements, fn el -> el.tag_name == "div" end)

      assert {:ok, matched_elements} = Document.query_selector_all(document, "p")
      assert length(matched_elements) == 1
      assert hd(matched_elements).tag_name == "p"
    end

    test "finds all elements that match a class selector" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["container"])
      div2 = Element.new(tag_name: "div", class_list: ["container", "large"])
      p = Element.new(tag_name: "p", class_list: ["text"])

      # Add elements to the document
      document = Node.append_child(document, div1)
      document = Node.append_child(document, div2)
      _div1 = Node.append_child(div1, p)

      # Test query_selector_all with class
      assert {:ok, matched_elements} = Document.query_selector_all(document, ".container")
      assert length(matched_elements) == 2
      assert Enum.all?(matched_elements, fn el -> "container" in el.class_list end)

      assert {:ok, matched_elements} = Document.query_selector_all(document, ".large")
      assert length(matched_elements) == 1
      assert "large" in hd(matched_elements).class_list
    end

    test "returns empty list when no elements match the selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")

      # Add elements to the document
      document = Node.append_child(document, div)

      # Test query_selector_all with non-existent elements
      assert {:ok, []} = Document.query_selector_all(document, "span")
      assert {:ok, []} = Document.query_selector_all(document, "#nonexistent")
      assert {:ok, []} = Document.query_selector_all(document, ".missing")
    end

    test "finds elements at different levels of nesting" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["level1"])
      div2 = Element.new(tag_name: "div", class_list: ["level2"])
      div3 = Element.new(tag_name: "div", class_list: ["level3"])

      # Create a nested structure
      document = Node.append_child(document, div1)
      div1 = Node.append_child(div1, div2)
      _div2 = Node.append_child(div2, div3)

      # Test query_selector_all finding elements at all levels
      assert {:ok, matched_elements} = Document.query_selector_all(document, "div")
      assert length(matched_elements) == 3
    end
  end
end
