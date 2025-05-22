defmodule GenDOM.Parser do
  alias GenDOM.{
    Document,
    Element,
    Text
  }

  def parse_from_string(string, mime_type \\ nil) do
    {:ok, children} = LiveViewNative.Template.Parser.parse_document(string, attributes_as_maps: true, strip_comments: true)

    document = Document.new([])

    children = create_elements_from_children(children, [])

    Enum.reduce(children, document, &Document.append_child(&2, &1))
  end

  defp create_elements_from_children([], elements), do: Enum.reverse(elements)

  defp create_elements_from_children([text | tail], nodes) when is_binary(text) do
    node = Text.new(whole_text: text)
    create_elements_from_children(tail, [node | nodes])
  end

  defp create_elements_from_children([{tag_name, attributes, children} | tail], nodes) do
    children = create_elements_from_children(children, [])

    element = Element.new(tag_name: tag_name, attributes: attributes)
    element = Enum.reduce(children, element, &Element.append_child(&2, &1))

    create_elements_from_children(tail, [element | nodes])
  end
end
