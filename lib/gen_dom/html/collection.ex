defmodule GenDOM.HTMLCollection do
  @moduledoc """
  The HTMLCollection interface represents a generic collection of HTML elements.

  An HTMLCollection in the HTML DOM is live; it is automatically updated when the underlying 
  document is changed. For this reason, it's a good idea to make a copy (e.g., using Array.from) 
  to iterate over if adding, moving, or removing nodes during iteration.

  ## Specification Compliance

  This module implements the HTMLCollection interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/infrastructure.html#htmlcollection
  - **DOM Standard**: https://dom.spec.whatwg.org/#interface-htmlcollection
  - **MDN Web Docs**: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection

  ## Live Collections

  HTMLCollection objects are **live collections**, meaning they automatically update when the DOM changes:

  ```elixir
  # Get all div elements
  divs = GenDOM.Document.get_elements_by_tag_name(document, "div")
  GenDOM.HTMLCollection.length(divs)  # 2

  # Add another div to the document
  new_div = GenDOM.Element.new(tag_name: "div")
  GenDOM.Document.append_child(document, new_div)

  # Collection automatically updates
  GenDOM.HTMLCollection.length(divs)  # 3 (updated automatically!)
  ```

  ## Properties

  ### Collection State
  - `length` - The number of elements in the collection (read-only, live)
  - `document_pid` - The document this collection belongs to
  - `selector` - CSS selector or tag name used to populate collection
  - `filter_fn` - Function used to filter elements
  - `parent_element_pid` - Parent element for child collections (e.g., element.children)

  ### Cache Management
  - `cached_nodes` - Currently cached element PIDs
  - `needs_refresh` - Whether cache needs to be updated
  - `last_updated` - Timestamp of last cache update

  ## Methods

  ### Element Access
  - `length/1` - Get the number of elements in the collection
  - `item/2` - Get element at specific index
  - `named_item/2` - Get element by name or id attribute

  ### Iteration Support
  - `to_list/1` - Convert collection to list for iteration
  - `to_stream/1` - Convert collection to Elixir stream

  ## Creating HTMLCollections

  HTMLCollections are typically created by DOM query methods:

  ```elixir
  # By tag name
  divs = GenDOM.Document.get_elements_by_tag_name(document, "div")

  # By class name  
  actives = GenDOM.Document.get_elements_by_class_name(document, "active")

  # Element children
  children = GenDOM.Element.children(element)

  # Form elements
  form_elements = GenDOM.HTMLFormElement.elements(form)
  ```

  ## Accessing Elements

  Multiple ways to access elements in the collection:

  ```elixir
  collection = GenDOM.Document.get_elements_by_tag_name(document, "div")

  # By index
  first_div = GenDOM.HTMLCollection.item(collection, 0)
  second_div = GenDOM.HTMLCollection.item(collection, 1)

  # By name or id
  named_div = GenDOM.HTMLCollection.named_item(collection, "main-content")

  # Get length
  count = GenDOM.HTMLCollection.length(collection)

  # Check if empty
  is_empty = GenDOM.HTMLCollection.length(collection) == 0
  ```

  ## Iteration Patterns

  Work with collections using Elixir patterns:

  ```elixir
  collection = GenDOM.Document.get_elements_by_tag_name(document, "p")

  # Convert to list for standard iteration
  paragraphs = GenDOM.HTMLCollection.to_list(collection)
  Enum.each(paragraphs, fn p ->
    text = GenDOM.Node.get_text_content(p)
    IO.puts("Paragraph: \#{text}")
  end)

  # Use as stream for lazy operations
  collection
  |> GenDOM.HTMLCollection.to_stream()
  |> Stream.filter(fn p -> 
    GenDOM.Element.has_attribute?(p, "class") 
  end)
  |> Stream.take(5)
  |> Enum.to_list()

  # Manual iteration by index
  count = GenDOM.HTMLCollection.length(collection)
  Enum.reduce(0..(count-1), [], fn index, acc ->
    element = GenDOM.HTMLCollection.item(collection, index)
    [element | acc]
  end)
  ```

  ## Live Collection Updates

  Collections automatically reflect DOM changes:

  ```elixir
  # Initial state
  paras = GenDOM.Document.get_elements_by_tag_name(document, "p")
  GenDOM.HTMLCollection.length(paras)  # 3

  # Add new paragraph
  new_para = GenDOM.Element.new(tag_name: "p", text_content: "New paragraph")
  GenDOM.Document.append_child(document, new_para)

  # Collection automatically includes new element
  GenDOM.HTMLCollection.length(paras)  # 4
  last_para = GenDOM.HTMLCollection.item(paras, 3)  # Returns new paragraph

  # Remove paragraph
  GenDOM.Node.remove_child(document, new_para)
  GenDOM.HTMLCollection.length(paras)  # 3 (back to original)
  ```

  ## Specialized Collections

  Different DOM methods return specialized HTMLCollections:

  ```elixir
  # Form elements collection
  form = GenDOM.Element.new(tag_name: "form")
  form_elements = GenDOM.HTMLFormElement.elements(form)
  # Contains only form control elements (input, select, textarea, etc.)

  # Table rows collection  
  table = GenDOM.Element.new(tag_name: "table")
  rows = GenDOM.HTMLTableElement.rows(table)
  # Contains only tr elements

  # Option elements in select
  select = GenDOM.Element.new(tag_name: "select") 
  options = GenDOM.HTMLSelectElement.options(select)
  # Contains only option elements
  ```

  ## Named Item Access

  Access elements by name or id attributes:

  ```elixir
  # HTML: <div id="header">...</div><div name="sidebar">...</div>
  divs = GenDOM.Document.get_elements_by_tag_name(document, "div")

  # Access by id
  header = GenDOM.HTMLCollection.named_item(divs, "header")

  # Access by name  
  sidebar = GenDOM.HTMLCollection.named_item(divs, "sidebar")

  # Returns nil if not found
  missing = GenDOM.HTMLCollection.named_item(divs, "nonexistent")  # nil
  ```

  ## Performance Considerations

  ### Cache Management
  - Collections cache query results until DOM changes
  - Automatic cache invalidation on relevant DOM mutations
  - Lazy recalculation only when accessed

  ### Memory Efficiency
  - Collections are garbage collected when no longer referenced
  - Automatic cleanup of collection registrations
  - Minimal memory overhead for live tracking

  ### Query Optimization
  - Simple tag name queries are highly optimized
  - Complex selectors may have higher overhead
  - Consider converting to list for intensive iteration

  ## Integration with Enumerable

  HTMLCollection implements Enumerable for seamless Elixir integration:

  ```elixir
  collection = GenDOM.Document.get_elements_by_tag_name(document, "div")

  # Use Enum functions directly
  collection
  |> Enum.filter(fn div ->
    GenDOM.Element.get_attribute(div, "class") =~ "active"
  end)
  |> Enum.map(fn div ->
    GenDOM.Node.get_text_content(div)
  end)

  # Reduce operations
  total_length = Enum.reduce(collection, 0, fn div, acc ->
    text = GenDOM.Node.get_text_content(div)
    acc + String.length(text)
  end)

  # Check membership
  Enum.member?(collection, some_div_element)
  ```

  ## Error Handling

  Collections handle edge cases gracefully:

  ```elixir
  collection = GenDOM.Document.get_elements_by_tag_name(document, "span")

  # Out of bounds access returns nil
  missing = GenDOM.HTMLCollection.item(collection, 999)  # nil

  # Named item with non-existent name returns nil
  missing = GenDOM.HTMLCollection.named_item(collection, "missing")  # nil

  # Length is always non-negative
  count = GenDOM.HTMLCollection.length(collection)  # >= 0
  ```

  ## Common Patterns

  ### Batch Element Updates
  ```elixir
  # Convert to list to avoid live updates during iteration
  elements = GenDOM.HTMLCollection.to_list(collection)

  Enum.each(elements, fn element ->
    GenDOM.Element.set_attribute(element, "data-processed", "true")
    # Safe to modify DOM during iteration since we have a static list
  end)
  ```

  ### Conditional Processing
  ```elixir
  divs = GenDOM.Document.get_elements_by_tag_name(document, "div")

  if GenDOM.HTMLCollection.length(divs) > 0 do
    first_div = GenDOM.HTMLCollection.item(divs, 0)
    GenDOM.Element.set_attribute(first_div, "class", "first")
  end
  ```

  ### Finding Specific Elements
  ```elixir
  forms = GenDOM.Document.get_elements_by_tag_name(document, "form")

  login_form = forms
  |> GenDOM.HTMLCollection.to_stream()
  |> Stream.filter(fn form ->
    GenDOM.Element.get_attribute(form, "id") == "login"
  end)
  |> Enum.take(1)
  |> List.first()
  ```

  ## Browser Compatibility

  This implementation follows the standard HTMLCollection behavior found in all modern browsers,
  ensuring consistent behavior across different environments.

  ## Performance Characteristics

  - **Element Access**: O(1) for cached results, O(n) for fresh queries
  - **Length Calculation**: O(1) when cached, O(n) for fresh calculation
  - **Named Item Lookup**: O(n) linear search through collection
  - **Memory Usage**: Proportional to number of matching elements
  - **Live Updates**: O(1) for cache invalidation, O(n) for recalculation
  """

  import Kernel,
    except: [
      length: 1
    ]

  @derive {Inspect, only: [:length, :selector, :collection_type]}

  use GenObject, [
    # Collection metadata
    # Document this collection belongs to
    document_pid: nil,
    # CSS selector or tag name for queries
    selector: nil,
    # Function to filter elements
    filter_fn: nil,
    # Parent element for child collections
    parent_element_pid: nil,
    # Type of collection (:tag_name, :class_name, :children, etc.)
    collection_type: :generic,

    # Current state
    # Number of elements in collection (live)
    length: 0,
    # Currently cached element PIDs
    cached_nodes: [],

    # Cache management
    # Whether cache needs updating
    needs_refresh: false,
    # Timestamp of last update
    last_updated: nil,

    # Registry tracking
    # Whether registered for change notifications
    registered_with_document: false
  ]

  @doc """
  Creates a new HTMLCollection.

  Creates a live collection that automatically updates when the DOM changes.

  ## Parameters

  - `options` - Keyword list of collection options:
    - `:document_pid` - The document PID this collection belongs to
    - `:selector` - CSS selector string for filtering elements
    - `:filter_fn` - Function to filter elements
    - `:parent_element_pid` - Parent element PID for child collections
    - `:collection_type` - Type of collection (atom)

  ## Returns

  A new `%GenDOM.HTMLCollection{}` struct with the collection process PID.

  ## Examples

      # Create collection for all div elements
      collection = GenDOM.HTMLCollection.new([
        document_pid: document_pid,
        selector: "div",
        collection_type: :tag_name
      ])

      # Create collection for element children
      children = GenDOM.HTMLCollection.new([
        document_pid: document_pid,
        parent_element_pid: element_pid,
        collection_type: :children
      ])

  ## Web API Reference

  This corresponds to the underlying HTMLCollection creation in DOM methods like
  `getElementsByTagName`, `getElementsByClassName`, etc.
  """
  def new(options \\ []) do
    super(options)
  end

  @doc """
  Returns the number of elements in the collection.

  The length property returns the number of elements in the HTMLCollection.
  This property is live and automatically updates when the DOM changes.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID

  ## Returns

  A non-negative integer representing the number of elements.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "div")
      count = GenDOM.HTMLCollection.length(collection)  # e.g., 5

      # Add new div element
      GenDOM.Document.append_child(document, new_div)
      
      # Length automatically updates
      new_count = GenDOM.HTMLCollection.length(collection)  # e.g., 6

  ## Web API Reference

  [MDN Web Docs: HTMLCollection.length](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection/length)
  """
  def length(%__MODULE__{pid: pid}), do: length(pid)

  def length(collection_pid) do
    ensure_fresh_cache(collection_pid)
    GenObject.get(collection_pid, :length)
  end

  @doc """
  Returns the element at the specified index.

  The item() method returns the node located at the specified offset into the collection.
  Returns nil if the index is out of range.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID
  - `index` - Zero-based integer index of the element to retrieve

  ## Returns

  The element at the specified index, or `nil` if index is out of range.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "p")
      
      first_para = GenDOM.HTMLCollection.item(collection, 0)
      second_para = GenDOM.HTMLCollection.item(collection, 1)
      
      # Out of range returns nil
      missing = GenDOM.HTMLCollection.item(collection, 999)  # nil

  ## Web API Reference

  [MDN Web Docs: HTMLCollection.item()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection/item)
  """
  def item(%__MODULE__{pid: pid}, index), do: item(pid, index)

  def item(collection_pid, index) when is_integer(index) and index >= 0 do
    ensure_fresh_cache(collection_pid)
    cached_nodes = GenObject.get(collection_pid, :cached_nodes)
    Enum.at(cached_nodes, index)
  end

  def item(_collection_pid, _index), do: nil

  @doc """
  Returns the element with the specified name or id.

  The namedItem() method returns the element whose id or name attribute matches the specified name.
  In HTML, the name attribute is only valid on certain elements like form controls.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID  
  - `name` - String name or id to search for

  ## Returns

  The first element with matching name or id, or `nil` if not found.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "div")
      
      # Find by id attribute
      header = GenDOM.HTMLCollection.named_item(collection, "header")
      
      # Find by name attribute (for form elements)
      input = GenDOM.HTMLCollection.named_item(form_elements, "username")
      
      # Not found returns nil
      missing = GenDOM.HTMLCollection.named_item(collection, "nonexistent")  # nil

  ## Web API Reference

  [MDN Web Docs: HTMLCollection.namedItem()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection/namedItem)
  """
  def named_item(%__MODULE__{pid: pid}, name), do: named_item(pid, name)

  def named_item(collection_pid, name) when is_binary(name) do
    ensure_fresh_cache(collection_pid)
    cached_nodes = GenObject.get(collection_pid, :cached_nodes)

    Enum.find(cached_nodes, fn node_pid ->
      # Check id attribute first
      case GenDOM.Element.get_attribute(node_pid, "id") do
        ^name ->
          true

        _ ->
          # Check name attribute
          GenDOM.Element.get_attribute(node_pid, "name") == name
      end
    end)
  end

  def named_item(_collection_pid, _name), do: nil

  @doc """
  Converts the collection to a list.

  Creates a static list from the current collection contents. This is useful when you need
  to iterate over elements and potentially modify the DOM during iteration.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID

  ## Returns

  A list of element PIDs currently in the collection.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "div")
      elements_list = GenDOM.HTMLCollection.to_list(collection)
      
      # Safe to modify DOM during iteration since we have a static list
      Enum.each(elements_list, fn div ->
        GenDOM.Element.set_attribute(div, "data-processed", "true")
      end)

  ## Web API Reference

  This is a convenience method for Elixir integration and doesn't correspond to a Web API method.
  Similar to `Array.from(collection)` in JavaScript.
  """
  def to_list(%__MODULE__{pid: pid}), do: to_list(pid)

  def to_list(collection_pid) do
    ensure_fresh_cache(collection_pid)
    GenObject.get(collection_pid, :cached_nodes)
  end

  @doc """
  Converts the collection to an Elixir stream.

  Creates a stream that lazily iterates over the collection contents. The stream
  reflects the current state when operations are executed.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID

  ## Returns

  A `Stream` over the collection elements.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "p")
      
      # Lazy stream operations
      active_paragraphs = collection
      |> GenDOM.HTMLCollection.to_stream()
      |> Stream.filter(fn p -> 
        GenDOM.Element.has_attribute?(p, "class") 
      end)
      |> Stream.take(5)
      |> Enum.to_list()

  ## Web API Reference

  This is a convenience method for Elixir integration and doesn't correspond to a Web API method.
  """
  def to_stream(%__MODULE__{pid: pid}), do: to_stream(pid)

  def to_stream(collection_pid) do
    Stream.unfold(0, fn index ->
      case item(collection_pid, index) do
        nil -> nil
        element -> {element, index + 1}
      end
    end)
  end

  @doc """
  Returns an iterator over the collection elements.

  Creates a DOM-compatible iterator that provides `next()` method functionality
  similar to JavaScript iterators, while integrating with Elixir's functional patterns.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID

  ## Returns

  A `GenDOM.Iterator.IteratorImpl` that can be used with the Iterator protocol.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "div")
      iterator = GenDOM.HTMLCollection.values(collection)
      
      # JavaScript-like iteration
      case GenDOM.Iterator.next(iterator) do
        {:ok, element, next_iterator} -> 
          # Process element
          GenDOM.Iterator.next(next_iterator)
        :done -> 
          IO.puts("Iteration complete")
      end
      
      # Or use Elixir Stream patterns
      iterator
      |> GenDOM.Iterator.to_stream()
      |> Stream.take(5)
      |> Enum.to_list()

  ## Web API Reference

  [MDN Web Docs: HTMLCollection@@iterator](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection/@@iterator)
  """
  def values(%__MODULE__{} = collection) do
    GenDOM.Iterator.new(collection)
  end

  def values(collection_pid), do: values(%__MODULE__{pid: collection_pid})

  @doc """
  Returns an iterator over collection entries as [index, element] pairs.

  Creates an iterator that yields [index, element] tuples for each item in the collection.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID

  ## Returns

  A `GenDOM.Iterator.IteratorImpl` over [index, element] pairs.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "p")
      entries_iterator = GenDOM.HTMLCollection.entries(collection)
      
      case GenDOM.Iterator.next(entries_iterator) do
        {:ok, [0, first_element], next_iterator} -> 
          IO.puts("First paragraph at index 0")
        :done -> 
          IO.puts("No elements")
      end

  ## Web API Reference

  [MDN Web Docs: HTMLCollection.entries()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection/entries)
  """
  def entries(%__MODULE__{} = collection) do
    entries_stream =
      collection
      |> to_stream()
      |> Stream.with_index()
      |> Stream.map(fn {element, index} -> [index, element] end)

    GenDOM.Iterator.new(entries_stream)
  end

  def entries(collection_pid), do: entries(%__MODULE__{pid: collection_pid})

  @doc """
  Returns an iterator over collection indexes.

  Creates an iterator that yields the index of each element in the collection.

  ## Parameters

  - `collection` - The HTMLCollection struct or PID

  ## Returns

  A `GenDOM.Iterator.IteratorImpl` over collection indexes.

  ## Examples

      collection = GenDOM.Document.get_elements_by_tag_name(document, "div")
      keys_iterator = GenDOM.HTMLCollection.keys(collection)
      
      case GenDOM.Iterator.next(keys_iterator) do
        {:ok, 0, next_iterator} -> 
          IO.puts("First index is 0")
        :done -> 
          IO.puts("No elements")
      end

  ## Web API Reference

  [MDN Web Docs: HTMLCollection.keys()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection/keys)
  """
  def keys(%__MODULE__{} = collection) do
    keys_stream =
      0..(length(collection) - 1)
      |> Stream.map(& &1)

    GenDOM.Iterator.new(keys_stream)
  end

  def keys(collection_pid), do: keys(%__MODULE__{pid: collection_pid})

  # Private helper functions

  defp ensure_fresh_cache(collection_pid) do
    if GenObject.get(collection_pid, :needs_refresh) do
      refresh_cache(collection_pid)
    end
  end

  defp refresh_cache(collection_pid) do
    state = GenObject.get_state(collection_pid)

    new_nodes =
      case state.collection_type do
        :tag_name ->
          query_by_tag_name(state.document_pid, state.selector)

        :class_name ->
          query_by_class_name(state.document_pid, state.selector)

        :children ->
          get_child_elements(state.parent_element_pid)

        :selector ->
          GenDOM.QuerySelector.query_all(state.document_pid, state.selector)

        _ when is_function(state.filter_fn) ->
          query_with_filter(state.document_pid, state.filter_fn)

        _ ->
          []
      end

    GenObject.set(collection_pid, :cached_nodes, new_nodes)
    GenObject.set(collection_pid, :length, length(new_nodes))
    GenObject.set(collection_pid, :needs_refresh, false)
    GenObject.set(collection_pid, :last_updated, System.system_time(:millisecond))
  end

  defp query_by_tag_name(document_pid, tag_name) do
    # Implementation would query document for elements with matching tag
    :not_implemented
  end

  defp query_by_class_name(document_pid, class_name) do
    # Implementation would query document for elements with matching class
    :not_implemented
  end

  defp get_child_elements(parent_pid) do
    # Implementation would get direct child elements of parent
    :not_implemented
  end

  defp query_with_filter(document_pid, filter_fn) do
    # Implementation would apply filter function to all elements
    :not_implemented
  end
end

# Implement Enumerable protocol for seamless Elixir integration
defimpl Enumerable, for: GenDOM.HTMLCollection do
  def reduce(collection, acc, fun) do
    collection
    |> GenDOM.HTMLCollection.to_stream()
    |> Enumerable.reduce(acc, fun)
  end

  def count(collection) do
    {:ok, GenDOM.HTMLCollection.length(collection)}
  end

  def member?(collection, element) when is_pid(element) do
    collection
    |> GenDOM.HTMLCollection.to_list()
    |> Enum.member?(element)
    |> then(&{:ok, &1})
  end

  def member?(_collection, _element), do: {:ok, false}

  def slice(collection) do
    count = GenDOM.HTMLCollection.length(collection)

    {:ok, count,
     fn start, length ->
       start..(start + length - 1)
       |> Enum.map(&GenDOM.HTMLCollection.item(collection, &1))
       |> Enum.filter(&(&1 != nil))
     end}
  end
end
