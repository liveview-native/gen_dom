defmodule GenDOM.Parser do
  alias GenDOM.{
    Document,
    Element,
    Text
  }

  def parse_from_string(string, _mime_type \\ nil, opts) do
    {:ok, children} =
      LiveViewNative.Template.Parser.parse_document(string,
        attributes_as_maps: true,
        strip_comments: true
      )

    document = Document.new([])


    children = create_elements_from_children(children, [])

    if receiver = opts[:receiver] do
      document = Document.put(document, :receiver, receiver)
      send(receiver, {:document, Document.encode(document)})
    end

    Enum.reduce(children, document, &Document.append_child(&2, &1, receiver: opts[:receiver]))
  end

  def parse_from_html(html, _mime_type \\ nil, opts) do
    {:ok, children} =
      Floki.parse_document(html,
        attributes_as_maps: true
      )

    document = Document.new([])

    # {children} = create_elements_from_children(children, [], 0)
    # :timer.tc fn ->
      children = create_elements_from_children(children, [])

      if receiver = opts[:receiver] do
        document = Document.put(document, :receiver, receiver)
        send(receiver, {:document, Document.encode(document)})
      end

      Enum.reduce(children, document, &Document.append_child(&2, &1, receiver: opts[:receiver]))
    # end
  end

  defp create_elements_from_children([], elements), do: elements

  defp create_elements_from_children([text | tail], nodes) when is_binary(text) do
    node = Text.new(whole_text: text)
    create_elements_from_children(tail, [node | nodes])
  end

  defp create_elements_from_children([{:comment, _comment} | tail], nodes) do
    create_elements_from_children(tail, nodes)
  end

  defp create_elements_from_children([{tag_name, attributes, children} | tail], nodes) do
    children = create_elements_from_children(children, [])

    element = Element.new(tag_name: tag_name, attributes: attributes)
    element = Enum.reduce(children, element, &Element.append_child(&2, &1))

    create_elements_from_children(tail, [element | nodes])
  end

  defp create_elements_from_children([other | tail], nodes) do
    create_elements_from_children(tail, nodes)
  end
end
