defmodule GenDOM.Parser do
  alias GenDOM.{
    Document,
    Element,
    Text
  }

  def parse_from_string(template, mime_type \\ nil, opts \\ [])

  def parse_from_string(html, "text/html", opts) do
    {:ok, children} =
      Floki.parse_document(html,
        attributes_as_maps: true
      )

    document = Document.new([
      content_type: "text/html",
      receiver: opts[:receiver],
      window: opts[:window],
      event_registry: opts[:event_registry]
    ])

    children = create_elements_from_children(children, [], document.pid)

    if receiver = opts[:receiver] do
      document = Document.put(document.pid, :receiver, receiver)
      send(receiver, {:document, Document.encode(document)})
    end

    Enum.reduce(children, document.pid, &Document.append_child(&2, &1, receiver: opts[:receiver]))
  end


  def parse_from_string(string, content_type, opts) do
    {:ok, children} =
      LiveViewNative.Template.Parser.parse_document(string,
        attributes_as_maps: true,
        strip_comments: true
      )

    document = Document.new([
      content_type: content_type,
      receiver: opts[:receiver],
      window: opts[:window],
      event_registry: opts[:event_registry]
    ])

    children_pids = create_elements_from_children(children, [], document.pid)

    if receiver = opts[:receiver] do
      Document.put(document.pid, :receiver, receiver)
      send(receiver, {:document, Document.encode(document.pid)})
    end

    Enum.reduce(children_pids, document.pid, &Document.append_child(&2, &1, receiver: opts[:receiver]))
  end

  defp create_elements_from_children([], node_pids, _document), do: node_pids

  defp create_elements_from_children([text | tail], node_pids, document_pid) when is_binary(text) do
    text_node = Text.new(whole_text: text)
    create_elements_from_children(tail, [text_node.pid | node_pids], document_pid)
  end

  defp create_elements_from_children([{:comment, _comment} | tail], node_pids, document_pid) do
    create_elements_from_children(tail, node_pids, document_pid)
  end

  defp create_elements_from_children([{tag_name, attributes, children} | tail], node_pids, document_pid) do
    children_pids = create_elements_from_children(children, [], document_pid)

    element = Element.new(
      tag_name: tag_name,
      owner_document: document_pid,
      attributes: attributes
    )

    Enum.each(Enum.reverse(children_pids), &Element.append_child(element.pid, &1))

    create_elements_from_children(tail, [element.pid | node_pids], document_pid)
  end

  defp create_elements_from_children([_other | tail], node_pids, document_pid) do
    create_elements_from_children(tail, node_pids, document_pid)
  end
end
