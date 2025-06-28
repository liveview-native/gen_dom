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
      div = Node.append_child(div, p)

      # Test query_selector with tag name
      matched_element = Document.query_selector(document, "div")
      assert matched_element.tag_name == "div"

      matched_element = Document.query_selector(document, "p")
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
      matched_element = Document.query_selector(document, "#main")
      assert matched_element.id == "main"

      matched_element = Document.query_selector(document, "#content")
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
      matched_element = Document.query_selector(document, ".container")
      assert "container" in matched_element.class_list

      matched_element = Document.query_selector(document, ".highlight")
      assert "highlight" in matched_element.class_list
    end

    test "returns error when no element matches the selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")

      # Add elements to the document
      document = Node.append_child(document, div)

      # Test query_selector with non-existent element
      refute Document.query_selector(document, "span")
      refute Document.query_selector(document, "#nonexistent")
      refute Document.query_selector(document, ".missing")
    end
  end

  describe "query_selector_all/2" do
    test "finds nested elements with attr query" do
      document = Document.new([])
      head = Element.new(tag_name: "head")
      text = Element.new(
        tag_name: "Text",
        attributes: %{
          "template" => "loading"
        }
      )

      head = Element.append_child(head, text)
      document = Document.append_child(document, head)

      text = GenServer.call(text.pid, :get)

      assert [text] == Document.query_selector_all(document, ~s(head [template="loading"]))
    end

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
      matched_elements = Document.query_selector_all(document, "div")
      assert length(matched_elements) == 2
      assert Enum.all?(matched_elements, fn el -> el.tag_name == "div" end)

      matched_elements = Document.query_selector_all(document, "p")
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
      matched_elements = Document.query_selector_all(document, ".container")
      assert length(matched_elements) == 2
      assert Enum.all?(matched_elements, fn el -> "container" in el.class_list end)

      matched_elements = Document.query_selector_all(document, ".large")
      assert length(matched_elements) == 1
      assert "large" in hd(matched_elements).class_list
    end

    test "returns empty list when no elements match the selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")

      # Add elements to the document
      document = Node.append_child(document, div)

      # Test query_selector_all with non-existent elements
      assert [] = Document.query_selector_all(document, "span")
      assert [] = Document.query_selector_all(document, "#nonexistent")
      assert [] = Document.query_selector_all(document, ".missing")
    end

    test "finds elements at different levels of nesting" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["level1"])
      div2 = Element.new(tag_name: "div", class_list: ["level2"])
      div3 = Element.new(tag_name: "div", class_list: ["level3"])

      # Create a nested structure
      document = Node.append_child(document, div1)
      _div1 = Node.append_child(div1, div2)
      _div2 = Node.append_child(div2, div3)

      # Test query_selector_all finding elements at all levels
      matched_elements = Document.query_selector_all(document, "div")
      assert length(matched_elements) == 3
    end
  end


  describe "pseudo selectors" do
    test ":not" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["level1"])
      div2 = Element.new(tag_name: "div", class_list: ["level2"])
      div3 = Element.new(tag_name: "div", class_list: ["level3"])

      document = Node.append_child(document, div1)
      div1 = Node.append_child(div1, div2)
      div1 = Node.append_child(div1, div3)

      div3 = GenServer.call(div3.pid, :get)

      document = GenServer.call(document.pid, :get)

      results = Document.query_selector_all(document, "div:not(.level2)")
      assert div1 in results
      assert div3 in results
      assert div3 in Document.query_selector_all(document, "div :not(.level2)")
    end

    test "very complex :not case" do
      html = """
        <div class="main-content" id="content1">
          <p>This paragraph should be selected.</p>
          <div class="container">
            <p data-status="inactive">This paragraph should be selected.</p>
            <p data-status="active">This paragraph should NOT be selected.</p>
          </div>
          <span class="info">Some info here.</span>
        </div>

        <div class="main-content" id="temp-div-1">
          <p>This entire div should NOT be selected.</p>
        </div>

        <div class="main-content" id="content2">
          <p>Another paragraph to be selected.</p>
        </div>
        """

      document = GenDOM.Parser.parse_from_html(html, nil, [])

      results = GenDOM.Document.query_selector_all(document, ~s'div:not(.container > p[data-status="active"]):not([id^="temp"])')

      assert Enum.any?(results, fn(div) ->
        div.id == "content1"
        && "main-content" in div.class_list
      end)

      assert Enum.any?(results, fn(div) ->
        div.id == ""
        && "container" in div.class_list
      end)

      assert Enum.any?(results, fn(div) ->
        div.id == "content2"
        && "main-content" in div.class_list
      end)
    end
  end
end
