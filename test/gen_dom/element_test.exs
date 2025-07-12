defmodule GenDOM.ElementTest do
  use ExUnit.Case, async: true

  alias GenDOM.{
    Document,
    Element,
    Node,
    Parser
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

      Element.append_child(parent.pid, element.pid)
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

  test "closest" do
    html = """
      <article>
        <div id="div-01">
          Here is div-01
          <div id="div-02">
            Here is div-02
            <div id="div-03">Here is div-03</div>
          </div>
        </div>
      </article>
      """

    document_pid = Parser.parse_from_string(html, "text/html")
    element_pid = Document.query_selector(document_pid, "#div-03")

    assert (Element.closest(element_pid, "#div-02") |> Element.get()).id == "div-02"
    assert (Element.closest(element_pid, "div div") |> Element.get()).id == "div-03"
    assert (Element.closest(element_pid, "article > div") |> Element.get()).id == "div-01"
    assert (Element.closest(element_pid, ":not(div)") |> Element.get()).tag_name == "article"
  end
end
