defmodule GenDOM.QueryTest do
  use ExUnit.Case, async: true

  alias GenDOM.{
    Document,
    Element,
    Node
  }

  describe "query_selector/2" do
    test "finds the first element that matches a tag selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")
      p = Element.new(tag_name: "p")

      # Add elements to the document
      Node.append_child(document.pid, div.pid)
      Node.append_child(div.pid, p.pid)

      # Test query_selector with tag name
      matched_element_pid = Document.query_selector(document.pid, "div")
      assert Element.get(matched_element_pid).tag_name == "div"

      matched_element_pid = Document.query_selector(document.pid, "p")
      assert Element.get(matched_element_pid).tag_name == "p"
    end

    test "finds the first element that matches an ID selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div", id: "main")
      p = Element.new(tag_name: "p", id: "content")

      # Add elements to the document
      Node.append_child(document.pid, div.pid)
      Node.append_child(div.pid, p.pid)

      # Test query_selector with ID
      matched_element_pid = Document.query_selector(document.pid, "#main")
      assert Element.get(matched_element_pid).id == "main"

      matched_element_pid = Document.query_selector(document.pid, "#content")
      assert Element.get(matched_element_pid).id == "content"
    end

    test "finds the first element that matches a class selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div", class_list: ["container"])
      p = Element.new(tag_name: "p", class_list: ["text", "highlight"])

      # Add elements to the document
      Node.append_child(document.pid, div.pid)
      Node.append_child(div.pid, p.pid)

      # Test query_selector with class
      matched_element_pid = Document.query_selector(document.pid, ".container")
      assert "container" in Element.get(matched_element_pid).class_list

      matched_element_pid = Document.query_selector(document.pid, ".highlight")
      assert "highlight" in Element.get(matched_element_pid).class_list
    end

    test "returns error when no element matches the selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")

      # Add elements to the document
      Node.append_child(document.pid, div.pid)

      # Test query_selector with non-existent element
      refute Document.query_selector(document.pid, "span")
      refute Document.query_selector(document.pid, "#nonexistent")
      refute Document.query_selector(document.pid, ".missing")
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

      Element.append_child(head.pid, text.pid)
      Document.append_child(document.pid, head.pid)

      assert [text.pid] == Document.query_selector_all(document.pid, ~s(head [template="loading"]))
    end

    test "finds all elements that match a tag selector" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div")
      div2 = Element.new(tag_name: "div")
      p = Element.new(tag_name: "p")

      # Add elements to the document
      Node.append_child(document.pid, div1.pid)
      Node.append_child(document.pid, div2.pid)
      Node.append_child(div1.pid, p.pid)

      # Test query_selector_all with tag name
      matched_element_pids = Document.query_selector_all(document.pid, "div")
      assert length(matched_element_pids) == 2
      assert Enum.all?(matched_element_pids, fn el_pid -> Element.get(el_pid).tag_name == "div" end)

      matched_element_pids = Document.query_selector_all(document.pid, "p")
      assert length(matched_element_pids) == 1
      assert (hd(matched_element_pids) |> Element.get()).tag_name == "p"
    end

    test "finds all elements that match a class selector" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["container"])
      div2 = Element.new(tag_name: "div", class_list: ["container", "large"])
      p = Element.new(tag_name: "p", class_list: ["text"])

      # Add elements to the document
      Node.append_child(document.pid, div1)
      Node.append_child(document.pid, div2)
      _div1 = Node.append_child(div1.pid, p.pid)

      # Test query_selector_all with class
      matched_element_pids = Document.query_selector_all(document.pid, ".container")
      assert length(matched_element_pids) == 2
      assert Enum.all?(matched_element_pids, fn el_pid -> "container" in Element.get(el_pid).class_list end)

      matched_element_pids = Document.query_selector_all(document.pid, ".large")
      assert length(matched_element_pids) == 1
      assert "large" in (hd(matched_element_pids) |> Element.get()).class_list
    end

    test "returns empty list when no elements match the selector" do
      document = Document.new([])
      div = Element.new(tag_name: "div")

      # Add elements to the document
      Node.append_child(document.pid, div)

      # Test query_selector_all with non-existent elements
      assert [] = Document.query_selector_all(document.pid, "span")
      assert [] = Document.query_selector_all(document.pid, "#nonexistent")
      assert [] = Document.query_selector_all(document.pid, ".missing")
    end

    test "finds elements at different levels of nesting" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["level1"])
      div2 = Element.new(tag_name: "div", class_list: ["level2"])
      div3 = Element.new(tag_name: "div", class_list: ["level3"])

      # Create a nested structure
      Node.append_child(document.pid, div1)
      Node.append_child(div1.pid, div2)
      Node.append_child(div2.pid, div3)

      # Test query_selector_all finding elements at all levels
      matched_elements = Document.query_selector_all(document.pid, "div")
      assert length(matched_elements) == 3
    end
  end

  describe "pseudo selectors" do
    test ":not" do
      document = Document.new([])
      div1 = Element.new(tag_name: "div", class_list: ["level1"])
      div2 = Element.new(tag_name: "div", class_list: ["level2"])
      div3 = Element.new(tag_name: "div", class_list: ["level3"])

      Node.append_child(document.pid, div1)
      Node.append_child(div1.pid, div2)
      Node.append_child(div1.pid, div3)

      div3 = GenServer.call(div3.pid, :get)

      results = Document.query_selector_all(document.pid, "div:not(.level2)")

      assert div1.pid in results
      assert div3.pid in results
      assert div3.pid in Document.query_selector_all(document.pid, "div :not(.level2)")
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

      document_pid = GenDOM.Parser.parse_from_string(html, "text/html", [])

      results = GenDOM.Document.query_selector_all(document_pid, ~s'div:not(.container > p[data-status="active"]):not([id^="temp"])')

      assert Enum.any?(results, fn(div_pid) ->
        div = Element.get(div_pid)
        div.id == "content1"
        && "main-content" in div.class_list
      end)

      assert Enum.any?(results, fn(div_pid) ->
        div = Element.get(div_pid)
        div.id == ""
        && "container" in div.class_list
      end)

      assert Enum.any?(results, fn(div_pid) ->
        div = Element.get(div_pid)
        div.id == "content2"
        && "main-content" in div.class_list
      end)
    end
  end
end
