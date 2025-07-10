defmodule GenDOM.Parser do
  alias GenDOM.{
    Document,
    Element,
    Text
  }

  def parse_from_string(template, mime_type \\ nil, opts)

  def parse_from_string(html, "text/html", opts) do
    {:ok, children} =
      Floki.parse_document(html,
        attributes_as_maps: true
      )

    document = Document.new([
      content_type: "text/html"
    ])

    children = create_elements_from_children(children, [], document)

    if receiver = opts[:receiver] do
      document = Document.put(document, :receiver, receiver)
      send(receiver, {:document, Document.encode(document)})
    end

    document = Enum.reduce(children, document, &Document.append_child(&2, &1, receiver: opts[:receiver]))

    Document.get(document.pid)
  end


  def parse_from_string(string, content_type, opts) do
    {:ok, children} =
      LiveViewNative.Template.Parser.parse_document(string,
        attributes_as_maps: true,
        strip_comments: true
      )

    document = Document.new([
      content_type: content_type
    ])

    children = create_elements_from_children(children, [], document)

    if receiver = opts[:receiver] do
      document = Document.put(document, :receiver, receiver)
      send(receiver, {:document, Document.encode(document)})
    end

    Enum.reduce(children, document, &Document.append_child(&2, &1, receiver: opts[:receiver]))
  end

  defp create_elements_from_children([], elements, _document), do: elements

  defp create_elements_from_children([text | tail], nodes, document) when is_binary(text) do
    node = Text.new(whole_text: text)
    create_elements_from_children(tail, [node | nodes], document)
  end

  defp create_elements_from_children([{:comment, _comment} | tail], nodes, document) do
    create_elements_from_children(tail, nodes, document)
  end

  defp create_elements_from_children([{tag_name, attributes, children} | tail], nodes, document) do
    children = create_elements_from_children(children, [], document)

    element = Element.new(
      tag_name: tag_name,
      owner_document: document.pid,
      attributes: attributes
    )
    element = Enum.reduce(Enum.reverse(children), element, &Element.append_child(&2, &1))

    create_elements_from_children(tail, [element | nodes], document)
  end

  defp create_elements_from_children([_other | tail], nodes, document) do
    create_elements_from_children(tail, nodes, document)
  end
end
