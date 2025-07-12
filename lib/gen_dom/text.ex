defmodule GenDOM.Text do
  @moduledoc """
  Text represents the textual content of an element or attribute.

  The `GenDOM.Text` module extends `GenDOM.Node` to provide text-specific functionality
  for DOM text nodes. It implements the DOM Text specification as defined by the Web API.

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Text (extends Node)
  ```

  **Inherits from:** `GenDOM.Node`  
  **File:** `lib/gen_dom/text.ex`  
  **Inheritance:** `use GenDOM.Node` (line 4)

  ## Usage

  ```elixir
  # Create a text node
  text_node = GenDOM.Text.new([text_content: "Hello World", whole_text: "Hello World"])

  # Text nodes are typically created by elements
  element = GenDOM.Element.new([tag_name: "p"])
  text = GenDOM.Text.new([text_content: "Paragraph content"])
  GenDOM.Node.append_child(element.pid, text.pid)
  ```

  ## Features

  - Text content storage and management
  - Inherits all Node functionality (DOM tree operations, process management, etc.)
  - Minimal interface optimized for text content
  - Support for text manipulation operations

  ## Additional Fields

  Beyond the base Node fields, Text adds:
  - `whole_text` - The complete text content of the node and adjacent text nodes
  - `assigned_slot` - The slot element this text node is assigned to (Shadow DOM)
  - `node_type` - Set to 3 (TEXT_NODE constant)

  ## Text Methods

  Text nodes have a minimal interface focused on text content management.
  All DOM Node methods are inherited and available.
  """

  @derive {Inspect, only: [:whole_text]}

  use GenDOM.Node, [
    node_type: 3,
    assigned_slot: nil,
    whole_text: nil
  ]

  @doc """
  Creates a copy of the text node.

  This method overrides the base Node `clone_node/2` to properly handle text-specific
  fields during cloning. It implements the DOM `cloneNode()` specification for text nodes.

  ## Parameters

  - `text_pid` - The PID of the text node to clone
  - `deep?` - Boolean indicating whether descendants should be cloned (default: false)

  ## Examples

      iex> text = GenDOM.Text.new([text_content: "Hello", whole_text: "Hello World"])
      iex> cloned_text_pid = GenDOM.Text.clone_node(text.pid)
      iex> cloned_text = GenDOM.Node.get(cloned_text_pid)
      iex> cloned_text.text_content
      "Hello"

  """
  def clone_node(text_pid, deep? \\ false) do
    text = get(text_pid)
    fields = Map.drop(text, [
      :__struct__,
      :pid,
      :receiver,
      :owner_document,
      :parent_element,
      :parent_node,
      :previous_sibling,
      :last_child,
      :first_child,
      :base_node,
      :child_nodes,

      :assigned_slot
    ]) |> Map.to_list()

    new_text = apply(text.__struct__, :new, [fields])

    if deep? do
      Enum.reduce(text.child_nodes, new_text.pid, fn(child_node_pid, new_text_pid) ->
        child_node = GenServer.call(child_node_pid, :get)
        append_child(new_text_pid, clone_node(child_node, deep?))
      end)
    else
      new_text.pid
    end
  end

  @doc """
  Encodes the text node into a serializable format.

  This method overrides the base Node `encode/1` to include text-specific fields
  in the encoded representation. Used for serialization and communication.

  ## Parameters

  - `text` - The text node struct to encode

  ## Examples

      iex> text = GenDOM.Text.new([text_content: "Hello", whole_text: "Hello World"])
      iex> encoded = GenDOM.Text.encode(text)
      iex> encoded.whole_text
      "Hello World"

  """
  def encode(text) do
    Map.merge(super(text), %{
      whole_text: text.whole_text
    })
  end

  @doc """
  Returns the list of fields that are allowed to be updated via owner document notifications.

  This method extends the base Node allowed fields to include text-specific fields
  that should trigger notifications when modified.

  ## Examples

      iex> GenDOM.Text.allowed_fields()
      [:whole_text]

  """
  def allowed_fields,
    do: super() ++ [:whole_text] 
end
