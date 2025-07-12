defmodule GenDOM.Text do
  @moduledoc """
  The Text interface represents the textual content of Element or Attr.

  The Text interface represents a text node in a DOM tree. Text nodes cannot have children.
  All text that appears in an HTML document is stored in Text nodes, including whitespace
  between elements, newlines, and any other textual content.

  ## Specification Compliance

  This module implements the DOM Text interface as defined by:
  - **W3C DOM Level 4**: https://www.w3.org/TR/dom/#text
  - **WHATWG DOM Standard**: https://dom.spec.whatwg.org/#text

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.CharacterData (extends Node)
      └── GenDOM.Text (extends CharacterData)
          ├── GenDOM.CDATASection (extends Text)
          └── GenDOM.Comment (extends CharacterData)
  ```

  **Inherits from:** `GenDOM.Node`  
  **File:** `lib/gen_dom/text.ex`  
  **Node Type:** 3 (TEXT_NODE)

  ## Properties

  ### Text Content
  - `text_content` - The text content of the node (inherited from Node)
  - `node_value` - The value of the text node (same as text_content)
  - `data` - Character data contained by the node (from CharacterData)
  - `length` - Number of characters in the data
  - `whole_text` - All text in logically adjacent text nodes

  ### Shadow DOM
  - `assigned_slot` - HTMLSlotElement this text node is assigned to

  ### Node Identity
  - `node_name` - Always "#text" for text nodes
  - `node_type` - Always 3 (TEXT_NODE)

  ## Methods

  ### Text Manipulation (CharacterData)
  - `substring_data/3` - Extract substring from text data
  - `append_data/2` - Append text to existing data
  - `insert_data/3` - Insert text at specified offset
  - `delete_data/3` - Delete text from specified range
  - `replace_data/4` - Replace text in specified range

  ### Text-Specific Operations
  - `split_text/2` - Split text node at specified offset
  - `whole_text/1` - Get combined text of adjacent text nodes

  ### Inherited from Node
  - `clone_node/2` - Create copy of text node
  - `normalize/1` - Merge adjacent text nodes
  - All other Node methods for tree manipulation

  ## Text Node Creation

  Text nodes are typically created through Document methods:

  ```elixir
  # Create through document
  document = GenDOM.Document.new([])
  text_node = GenDOM.Document.create_text_node(document.pid, "Hello World")

  # Create directly (less common)
  text_node = GenDOM.Text.new([
    text_content: "Hello World",
    node_value: "Hello World"
  ])
  ```

  ## Text Content Handling

  Text nodes store textual content including:
  - **Visible Text**: Regular text content displayed to users
  - **Whitespace**: Spaces, tabs, newlines between elements
  - **Special Characters**: Unicode characters, entities
  - **Empty Text**: Zero-length text nodes (valid but often normalized away)

  ```elixir
  # Various types of text content
  regular_text = GenDOM.Document.create_text_node(doc.pid, "Hello World")
  whitespace = GenDOM.Document.create_text_node(doc.pid, "   \\n\\t   ")
  unicode_text = GenDOM.Document.create_text_node(doc.pid, "你好世界")
  empty_text = GenDOM.Document.create_text_node(doc.pid, "")
  ```

  ## Text Normalization

  Adjacent text nodes can be merged through normalization:

  ```elixir
  element = GenDOM.Element.new([tag_name: "p"])
  text1 = GenDOM.Document.create_text_node(doc.pid, "Hello ")
  text2 = GenDOM.Document.create_text_node(doc.pid, "World")

  GenDOM.Node.append_child(element.pid, text1.pid)
  GenDOM.Node.append_child(element.pid, text2.pid)

  # Before normalization: two separate text nodes
  # After normalization: single text node with "Hello World"
  GenDOM.Node.normalize(element.pid)
  ```

  ## Shadow DOM Integration

  Text nodes can be assigned to slots in Shadow DOM:

  ```elixir
  # Text node assigned to a slot
  text = GenDOM.Document.create_text_node(doc.pid, "Slotted content")
  slot = GenDOM.Element.new([tag_name: "slot", attributes: %{"name" => "content"}])

  # Text gets assigned_slot property when distributed
  ```

  ## Usage Examples

  ```elixir
  # Create a paragraph with text content
  document = GenDOM.Document.new([])
  paragraph = GenDOM.Document.create_element(document.pid, "p")
  text = GenDOM.Document.create_text_node(document.pid, "This is a paragraph.")

  GenDOM.Node.append_child(paragraph.pid, text.pid)

  # Split text node
  {left_text, right_text} = GenDOM.Text.split_text(text.pid, 7)
  # left_text.data = "This is"
  # right_text.data = " a paragraph."

  # Manipulate text content
  GenDOM.Text.append_data(left_text.pid, " really")
  # left_text.data = "This is really"

  # Get whole text across adjacent nodes
  combined = GenDOM.Text.whole_text(left_text.pid)
  # "This is really a paragraph."
  ```

  ## Performance Characteristics

  - **Creation**: O(1) - Text nodes have minimal overhead
  - **Content Access**: O(1) - Direct property access
  - **Text Operations**: O(n) where n is text length
  - **Normalization**: O(n) where n is number of adjacent text nodes

  ## Memory Efficiency

  Text nodes are designed for efficiency:
  - **Minimal State**: Only essential text properties
  - **String Optimization**: Elixir's efficient string handling
  - **Process Overhead**: ~2KB per text node process

  ## Text Encoding and Unicode

  Full Unicode support:
  - **UTF-8**: Native Elixir string encoding
  - **Character Boundaries**: Proper handling of multi-byte characters
  - **Normalization**: Unicode normalization forms supported
  - **Entities**: HTML entity decoding when appropriate

  ## Event Handling

  Text nodes can be event targets:
  - **Text Events**: Limited event support compared to elements
  - **Mutation Events**: Text changes trigger mutation observers
  - **Selection Events**: Participate in text selection

  ## Serialization

  Text nodes serialize to their text content:

  ```elixir
  text = GenDOM.Document.create_text_node(doc.pid, "Hello & goodbye")
  # Serialized as: "Hello &amp; goodbye" (entities escaped)
  ```

  ## Thread Safety

  Text operations are thread-safe:
  - **Atomic Updates**: Text content changes are atomic
  - **Concurrent Access**: Multiple readers safe
  - **Consistent State**: GenServer ensures consistency

  ## Common Patterns

  ### Text Insertion
  ```elixir
  # Insert text at beginning of element
  first_text = GenDOM.Document.create_text_node(doc.pid, "Start: ")
  GenDOM.Element.prepend(element.pid, [first_text])

  # Insert text at end
  last_text = GenDOM.Document.create_text_node(doc.pid, " :End")
  GenDOM.Element.append(element.pid, [last_text])
  ```

  ### Text Search and Replace
  ```elixir
  # Find and replace text content
  text_content = GenDOM.Node.get(text.pid).text_content
  new_content = String.replace(text_content, "old", "new")
  GenDOM.Node.put(text.pid, :text_content, new_content)
  ```

  ### Dynamic Text Updates
  ```elixir
  # Update text content dynamically
  GenDOM.Node.put(text.pid, :text_content, "Updated content")
  # Automatically updates node_value and triggers events
  ```
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
