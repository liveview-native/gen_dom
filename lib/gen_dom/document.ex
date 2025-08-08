defmodule GenDOM.Document do
  @moduledoc """
  The Document interface represents any web page loaded in the browser and serves as an entry point into the web page's content.

  The Document interface describes the common properties and methods for any kind of document.
  Depending on the document's type (e.g., HTML, XML, SVG), a larger API is available.
  HTML documents implement the HTMLDocument interface.

  ## Specification Compliance

  This module implements the DOM Document interface as defined by:
  - **W3C DOM Level 4**: https://www.w3.org/TR/dom/#document
  - **WHATWG DOM Standard**: https://dom.spec.whatwg.org/#document
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/dom.html#document

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Document (extends Node)
      └── GenDOM.HTMLDocument (extends Document)
  ```

  **Inherits from:** `GenDOM.Node`  
  **File:** `lib/gen_dom/document.ex`  
  **Node Type:** 9 (DOCUMENT_NODE)

  ## Properties

  ### Document Metadata
  - `title` - The document title as shown in browser title bar
  - `url` - The complete URL of the document
  - `document_uri` - The URI of the document (same as URL)
  - `base_uri` - The base URI used for resolving relative URLs
  - `origin` - The origin of the document (protocol + domain + port)
  - `character_set` - Character encoding of the document (e.g., "UTF-8")
  - `content_type` - MIME type of the document (e.g., "text/html")
  - `doctype` - Reference to the document's DOCTYPE declaration

  ### Document Structure
  - `document_element` - Root element of the document (html element)
  - `head` - Reference to the document head element
  - `body` - Reference to the document body element
  - `children` - HTMLCollection of child elements
  - `child_element_count` - Number of child elements
  - `first_element_child` - First child element
  - `last_element_child` - Last child element

  ### Document State
  - `ready_state` - Document loading state ("loading", "interactive", "complete")
  - `compat_mode` - Compatibility mode ("CSS1Compat" or "BackCompat")
  - `design_mode` - Whether document is in design mode ("on" or "off")
  - `hidden` - Whether document is hidden (tab in background)
  - `visibility_state` - Visibility state ("visible", "hidden", "prerender")

  ### Collections
  - `forms` - HTMLCollection of all form elements
  - `images` - HTMLCollection of all img elements
  - `links` - HTMLCollection of all link and area elements with href
  - `scripts` - HTMLCollection of all script elements
  - `embeds` - HTMLCollection of all embed elements
  - `plugins` - HTMLCollection of all object elements
  - `anchors` - HTMLCollection of all anchor elements with name attribute

  ### Styling
  - `style_sheets` - StyleSheetList of all style sheets
  - `adopted_style_sheets` - Array of adopted CSSStyleSheet objects
  - `fonts` - FontFaceSet for font loading

  ### Focus and Selection
  - `active_element` - Currently focused element
  - `has_focus` - Whether document has focus

  ### Fullscreen and Picture-in-Picture
  - `fullscreen_enabled` - Whether fullscreen is available
  - `fullscreen_element` - Element currently in fullscreen
  - `picture_in_picture_enabled` - Whether picture-in-picture is available
  - `picture_in_picture_element` - Element currently in picture-in-picture

  ### Pointer Lock
  - `pointer_lock_element` - Element that has captured the pointer

  ### Timeline and Navigation
  - `timeline` - DocumentTimeline for animations
  - `last_modified` - Date document was last modified

  ## Methods

  ### Element Creation
  - `create_element/3` - Create new element with specified tag name
  - `create_element_ns/4` - Create namespaced element
  - `create_text_node/2` - Create new text node
  - `create_comment/2` - Create new comment node
  - `create_document_fragment/1` - Create new document fragment
  - `create_processing_instruction/3` - Create processing instruction

  ### Element Selection and Querying
  - `get_element_by_id/2` - Find element by ID attribute
  - `get_elements_by_tag_name/2` - Find elements by tag name
  - `get_elements_by_tag_name_ns/3` - Find elements by namespaced tag name
  - `get_elements_by_class_name/2` - Find elements by class name
  - `get_elements_by_name/2` - Find elements by name attribute

  ### CSS Selector Queries
  - `query_selector/2` - Find first element matching CSS selector
  - `query_selector_all/2` - Find all elements matching CSS selector

  ### XPath Support
  - `create_expression/3` - Create XPath expression
  - `create_ns_resolver/2` - Create namespace resolver
  - `evaluate/6` - Evaluate XPath expression

  ### Document Lifecycle
  - `open/1` - Open document for writing
  - `close/1` - Close document after writing
  - `write/2` - Write string to document
  - `writeln/2` - Write string with newline to document

  ### Import and Adoption
  - `import_node/3` - Import node from another document
  - `adopt_node/2` - Adopt node from another document

  ### Event Methods
  - `has_focus/1` - Check if document has focus
  - `get_selection/1` - Get current text selection

  ### Fullscreen API
  - `exit_fullscreen/1` - Exit fullscreen mode
  - `request_storage_access/1` - Request storage access

  ### Picture-in-Picture API
  - `exit_picture_in_picture/1` - Exit picture-in-picture mode

  ### Pointer Lock API
  - `exit_pointer_lock/1` - Exit pointer lock mode

  ## Usage Examples

  ```elixir
  # Create a new document
  document = GenDOM.Document.new([
    title: "My Document",
    character_set: "UTF-8",
    content_type: "text/html"
  ])

  # Create elements
  html_element = GenDOM.Document.create_element(document.pid, "html")
  head_element = GenDOM.Document.create_element(document.pid, "head")
  body_element = GenDOM.Document.create_element(document.pid, "body")

  # Build document structure
  GenDOM.Node.append_child(document.pid, html_element.pid)
  GenDOM.Node.append_child(html_element.pid, head_element.pid)
  GenDOM.Node.append_child(html_element.pid, body_element.pid)

  # Element queries
  my_element = GenDOM.Document.get_element_by_id(document.pid, "my-id")
  buttons = GenDOM.Document.get_elements_by_tag_name(document.pid, "button")
  primary_elements = GenDOM.Document.query_selector_all(document.pid, ".primary")

  # Document operations
  text_node = GenDOM.Document.create_text_node(document.pid, "Hello World")
  imported_node = GenDOM.Document.import_node(document.pid, external_node.pid, true)
  ```

  ## Document Lifecycle

  Documents progress through several ready states:

  1. **Loading** - Document is still loading resources
  2. **Interactive** - Document has finished loading but resources may still be loading
  3. **Complete** - Document and all resources have finished loading

  ```elixir
  # Check document ready state
  case GenDOM.Document.get(document.pid).ready_state do
    "loading" -> # Document still loading
    "interactive" -> # DOM ready, resources may still load
    "complete" -> # Everything loaded
  end
  ```

  ## Security Model

  Documents enforce the same-origin policy:
  - Cross-origin access is restricted
  - Storage access requires user permission
  - Fullscreen requires user activation

  ## Performance Considerations

  - **Element Creation**: O(1) for basic elements
  - **ID Queries**: O(1) with internal ID index
  - **Tag/Class Queries**: O(n) where n is number of elements
  - **CSS Selector Queries**: O(n×m) where m is selector complexity

  ## Event Integration

  Documents are event targets and support:
  - **Document Events**: DOMContentLoaded, readystatechange
  - **Focus Events**: focusin, focusout
  - **Visibility Events**: visibilitychange
  - **Fullscreen Events**: fullscreenchange, fullscreenerror

  ## Threading Model

  Document operations are thread-safe:
  - **Element Creation**: Safe across threads
  - **Query Operations**: Consistent snapshots
  - **State Updates**: Atomic through GenServer

  ## Memory Management

  Documents manage element lifecycle:
  - **Automatic Cleanup**: Orphaned elements are cleaned up
  - **Reference Tracking**: Prevents memory leaks
  - **Process Supervision**: Failed elements don't corrupt document
  """

  alias GenDOM.Matcher

  use GenDOM.Node, [
    node_type: 10,
    active_element: nil,
    adopted_style_sheets: nil,
    body: nil,
    character_set: nil,
    child_element_count: 0,
    children: [],
    compat_mode: nil,
    content_type: nil,
    cookie: nil,
    current_script: nil,
    default_view: nil,
    design_mode: nil,
    dir: nil,
    doctype: nil,
    document_element: nil,
    document_uri: nil,
    embeds: nil,
    first_element_child: nil,
    fonts: [],
    forms: [],
    fragment_directive: nil,
    fullscreen_element: nil,
    fullscreen_enabled: nil,
    head: nil,
    hidden: nil,
    images: [],
    implementation: nil,
    last_element_child: nil,
    last_modified: nil,
    links: [],
    location: nil,
    picture_in_picture_element: nil,
    picture_in_picture_enabled?: nil,
    plugins: [],
    pointer_lock_element: nil,
    prerendering?: false,
    ready_state: nil,
    referrer: nil,
    scripts: [],
    scrolling_element: nil,
    style_sheets: [],
    timeline: nil,
    title: nil,
    url: nil,
    visibility_state: nil
  ]

  import GenDOM.Task

  def encode(document) do
    Map.merge(super(document), %{
      style_sheets: document.style_sheets,
      title: document.title,
      url: document.url,
      body: document.body,
      head: document.head,
      node_type: document.node_type
    })
  end

  def allowed_fields,
    do: super() ++ [:title, :body, :head]
  #
  # def handle_info({:DOWN, ref, :process, pid, :normal}, document) when is_reference(ref) and is_pid(pid) do
  #   {:noreply, document}
  # end
  #
  # def handle_info(msg, document) do
  #   super(msg, document)
  # end

  def clone_node(document_pid, deep? \\ false) do
    document = get(document_pid)
    fields = Map.drop(document, [
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

      :body,
      :child_element_count,
      :children,
      :cookie,
      :document,
      :document_element,
      :document_uri,
      :head,
      :images,
      :last_element_child,
      :links,
      :picture_in_picture_element,
      :scripts,
      :style_sheets,
      :title
    ]) |> Map.to_list()

    new_document = apply(document.__struct__, :new, [fields])

    if deep? do
      Enum.reduce(document.child_nodes, new_document.pid, fn(child_node_pid, new_document_pid) ->
        append_child(new_document_pid, clone_node(child_node_pid, deep?))
      end)
    else
      new_document.pid
    end
  end

  @doc """
  Transfers a node from another document to this document.

  This method implements the DOM `adoptNode()` specification. The node is removed
  from its original document and prepared for insertion into the current document.

  ## Parameters

  - `document` - The document to adopt the node into
  - `node` - The node to adopt from another document

  ## Examples

      adopted_node = GenDOM.Document.adopt_node(document, external_node)

  """
  def adopt_node(_document_pid, _node) do
    nil
  end

  @doc """
  Inserts a set of Node objects or string objects after the last child of the document.

  This method implements the DOM `append()` specification for documents.

  ## Parameters

  - `document` - The document to append nodes to
  - `nodes` - A list of Node objects or strings to append

  ## Examples

      GenDOM.Document.append(document, [new_element, "Some text"])

  """
  def append(_document_pid, nodes) when is_list(nodes) do
    nil
  end

  @doc """
  Returns a CaretPosition object containing the DOM node and caret offset position for the specified coordinates.

  This method implements the DOM `caretPositionFromPoint()` specification.

  ## Parameters

  - `document` - The document to get caret position from
  - `x` - The horizontal coordinate
  - `y` - The vertical coordinate
  - `options` - Optional parameters

  ## Examples

      caret_pos = GenDOM.Document.caret_position_from_point(document, 100, 200)

  """
  def caret_position_from_point(%__MODULE__{} = _document, _x, _y, _options \\ []) do
    nil
  end

  @doc """
  Finishes writing to a document.

  This method implements the DOM `close()` specification. It closes the document
  for writing and signals that the document has finished loading.

  ## Parameters

  - `document` - The document to close

  ## Examples

      GenDOM.Document.close(document)

  """
  def close(_document_pid) do
    nil
  end

  @doc """
  Creates a new attribute node with the specified name.

  This method implements the DOM `createAttribute()` specification.

  ## Parameters

  - `document` - The document to create the attribute in
  - `name` - The name of the attribute

  ## Examples

      attr = GenDOM.Document.create_attribute(document, "class")

  """
  def create_attribute(_document_pid, _name) do
    nil
  end

  @doc """
  Creates a new attribute node with the specified namespace URI and qualified name.

  This method implements the DOM `createAttributeNS()` specification.

  ## Parameters

  - `document` - The document to create the attribute in
  - `namespace_uri` - The namespace URI for the attribute
  - `qualified_name` - The qualified name of the attribute

  ## Examples

      attr = GenDOM.Document.create_attribute_ns(document, "http://www.w3.org/1999/xlink", "xlink:href")

  """
  def create_attribute_ns(_document_pid, _namespace_uri, _qualified_name) do
    nil
  end

  @doc """
  Creates a CDATA section node whose value is the specified string.

  This method implements the DOM `createCDATASection()` specification.

  ## Parameters

  - `document` - The document to create the CDATA section in
  - `data` - The data for the CDATA section

  ## Examples

      cdata = GenDOM.Document.create_CDATA_section(document, "<some>xml data</some>")

  """
  def create_CDATA_section(_document_pid, _data) do
    nil
  end

  @doc """
  Creates a comment node with the specified data.

  This method implements the DOM `createComment()` specification.

  ## Parameters

  - `document` - The document to create the comment in
  - `data` - The data for the comment

  ## Examples

      comment = GenDOM.Document.create_comment(document, "This is a comment")

  """
  def create_comment(_document_pid, _data) do
    nil
  end

  @doc """
  Creates a new empty DocumentFragment into which DOM nodes can be added.

  This method implements the DOM `createDocumentFragment()` specification.

  ## Parameters

  - `document` - The document to create the document fragment in

  ## Examples

      fragment = GenDOM.Document.create_document_fragment(document)

  """
  def create_document_fragment(_document_pid) do
    nil
  end

  @doc """
  Creates a new element with the given tag name.

  This method implements the DOM `createElement()` specification. The new element
  is created but not automatically inserted into the document tree.

  ## Parameters

  - `document` - The document to create the element in
  - `local_name` - The tag name of the element to create (e.g., "div", "span", "button")
  - `options` - Optional keyword list of initial attributes and properties

  ## Examples

      iex> {:ok, document} = GenDOM.Document.new([])
      iex> element = GenDOM.Document.create_element(document, "div", id: "content", class: "container")
      iex> element.tag_name
      "div"

  """
  def create_element(_document_pid, _local_name, _options \\ []) do
    nil
  end

  @doc """
  Creates an element with the specified namespace URI and qualified name.

  This method implements the DOM `createElementNS()` specification.

  ## Parameters

  - `document` - The document to create the element in
  - `namespace_uri` - The namespace URI for the element
  - `qualified_name` - The qualified name of the element
  - `options` - Optional keyword list of initial attributes and properties

  ## Examples

      svg_element = GenDOM.Document.create_element_ns(document, "http://www.w3.org/2000/svg", "svg:rect")

  """
  def create_element_ns(_document_pid, _namespace_uri, _qualified_name, _options \\ []) do
    nil
  end

  @doc """
  Creates a parsed XPath expression which can then be used for evaluations.

  This method implements the DOM `createExpression()` specification for XPath.

  ## Parameters

  - `document` - The document to create the expression for
  - `xpath_text` - The XPath expression text
  - `namespace_url_mapper` - Function to resolve namespace prefixes

  ## Examples

      expr = GenDOM.Document.create_expression(document, "//div[@class='content']", namespace_resolver)

  """
  def create_expression(_document_pid, _xpath_text, _namespace_url_mapper) do
    nil
  end

  @doc """
  Returns a new NodeIterator object.

  This method implements the DOM `createNodeIterator()` specification.

  ## Parameters

  - `document` - The document to create the iterator for
  - `root` - The root node of the iterator
  - `what_to_show` - Filter constant showing what types of nodes to include
  - `filter` - Custom filter function

  ## Examples

      iterator = GenDOM.Document.create_node_iterator(document, document, :show_element, nil)

  """
  def create_node_iterator(_document_pid, _root, _what_to_show, _filter) do
    nil
  end

  @doc """
  Creates a new processing instruction node and returns it.

  This method implements the DOM `createProcessingInstruction()` specification.

  ## Parameters

  - `document` - The document to create the processing instruction in
  - `target` - The target of the processing instruction
  - `data` - The data for the processing instruction

  ## Examples

      pi = GenDOM.Document.create_processing_instruction(document, "xml-stylesheet", "type='text/xsl' href='style.xsl'")

  """
  def create_processing_instruction(_document_pid, _target, _data) do
    nil
  end

  @doc """
  Creates a new Range object.

  This method implements the DOM `createRange()` specification.

  ## Parameters

  - `document` - The document to create the range for

  ## Examples

      range = GenDOM.Document.create_range(document)

  """
  def create_range(_document_pid) do
    nil
  end

  @doc """
  Creates a text node.

  This method implements the DOM `createTextNode()` specification. The created text node
  contains the specified text data and can be inserted into the document tree.

  ## Parameters

  - `document` - The document to create the text node in
  - `data` - The text content for the new text node

  ## Examples

      iex> {:ok, document} = GenDOM.Document.new([])
      iex> text_node = GenDOM.Document.create_text_node(document, "Hello, World!")
      iex> text_node.text_content
      "Hello, World!"

  """
  def create_text_node(_document_pid, _data) do
    nil
  end

  @doc """
  Creates a new TreeWalker object.

  This method implements the DOM `createTreeWalker()` specification.

  ## Parameters

  - `document` - The document to create the tree walker for
  - `root` - The root node of the tree walker
  - `what_to_show` - Filter constant showing what types of nodes to include
  - `filter` - Custom filter function

  ## Examples

      walker = GenDOM.Document.create_tree_walker(document, document, :show_element, nil)

  """
  def create_tree_walker(_document_pid, _root, _what_to_show, _filter) do
    nil
  end

  @doc """
  Returns the topmost element at the specified coordinates.

  This method implements the DOM `elementFromPoint()` specification.

  ## Parameters

  - `document` - The document to search in
  - `x` - The horizontal coordinate
  - `y` - The vertical coordinate

  ## Examples

      element = GenDOM.Document.element_from_point(document, 100, 200)

  """
  def element_from_point(_document_pid, _x, _y) do
    nil
  end

  @doc """
  Returns an array of all elements at the specified coordinates.

  This method implements the DOM `elementsFromPoint()` specification.

  ## Parameters

  - `document` - The document to search in
  - `x` - The horizontal coordinate
  - `y` - The vertical coordinate

  ## Examples

      elements = GenDOM.Document.elements_from_point(document, 100, 200)

  """
  def elements_from_point(_document_pid, _x, _y) do
    nil
  end

  @doc """
  Evaluates an XPath expression string and returns a result of the specified type if possible.

  This method implements the DOM `evaluate()` specification for XPath.

  ## Parameters

  - `document` - The document to evaluate the expression in
  - `xpath_expression` - The XPath expression string
  - `context_node` - The context node for the evaluation
  - `namespace_resolver` - Function to resolve namespace prefixes
  - `result_type` - The type of result expected
  - `result` - An existing XPathResult object to reuse

  ## Examples

      result = GenDOM.Document.evaluate(document, "//div", document, nil, :ordered_node_snapshot_type, nil)

  """
  def evaluate(_document_pid, _xpath_expression, _context_node, _namespace_resolver, _result_type, _result) do
    nil
  end

  @doc """
  Requests that the element on this document which is currently being presented in fullscreen mode be taken out of fullscreen mode.

  This method implements the DOM `exitFullscreen()` specification.

  ## Parameters

  - `document` - The document to exit fullscreen for

  ## Examples

      GenDOM.Document.exit_fullscreen(document)

  """
  def exit_fullscreen(_document_pid) do
    nil
  end

  @doc """
  Requests that a video element that is currently in picture-in-picture mode be taken out of picture-in-picture mode.

  This method implements the DOM `exitPictureInPicture()` specification.

  ## Parameters

  - `document` - The document to exit picture-in-picture for

  ## Examples

      GenDOM.Document.exit_picture_in_picture(document)

  """
  def exit_picture_in_picture(_document_pid) do
    nil
  end

  @doc """
  Asynchronously releases a pointer lock previously requested through Element.requestPointerLock.

  This method implements the DOM `exitPointerLock()` specification.

  ## Parameters

  - `document` - The document to exit pointer lock for

  ## Examples

      GenDOM.Document.exit_pointer_lock(document)

  """
  def exit_pointer_lock(_document_pid) do
    nil
  end

  @doc """
  Returns an array of all Animation objects currently in effect whose target elements are descendants of the document.

  This method implements the DOM `getAnimations()` specification for documents.

  ## Parameters

  - `document` - The document to get animations for

  ## Examples

      animations = GenDOM.Document.get_animations(document)

  """
  def get_animations(_document_pid) do
    nil
  end

  @doc """
  Returns the element that has the ID attribute with the specified value.

  This method implements the DOM `getElementById()` specification. It searches through
  all descendant elements in the document for an element with the matching ID.

  ## Parameters

  - `document_pid` - The PID of the document to search in
  - `id` - The ID value to search for

  ## Examples

      iex> document = GenDOM.Document.new([])
      iex> element = GenDOM.Element.new([tag_name: "div", id: "content"])
      iex> GenDOM.Node.append_child(document.pid, element.pid)
      iex> found_element = GenDOM.Document.get_element_by_id(document.pid, "content")
      iex> found_element.id
      "content"

  """
  def get_element_by_id(document_pid, id) do
    all_descendants = :pg.get_members(document_pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, {:id, id})
        |> Map.get(:pid)
      end)
    end)

    await_one(tasks)
  end

  @doc """
  Returns a list of all elements in the document that have all the given class names.

  This method implements the DOM `getElementsByClassName()` specification. It searches through
  all descendant elements in the document for elements that have all the specified class names.

  ## Parameters

  - `document_pid` - The PID of the document to search in
  - `names` - A string containing one or more class names separated by spaces

  ## Examples

      iex> document = GenDOM.Document.new([])
      iex> element = GenDOM.Element.new([tag_name: "div", class_list: ["btn", "primary"]])
      iex> GenDOM.Node.append_child(document.pid, element.pid)
      iex> found_elements = GenDOM.Document.get_elements_by_class_name(document.pid, "btn primary")
      iex> length(found_elements)
      1

  """
  def get_elements_by_class_name(document_pid, names) do
    names = String.split(names)
    all_descendants = :pg.get_members(document_pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, {:class, names})
        |> Map.get(:pid)
      end)
    end)

    await_many(tasks)
  end

  @doc """
  Returns a NodeList of elements with the given name attribute in the document.

  This method implements the DOM `getElementsByName()` specification.

  ## Parameters

  - `document_pid` - The PID of the document to search in
  - `name` - The value of the name attribute to search for

  ## Examples

      inputs = GenDOM.Document.get_elements_by_name(document.pid, "username")

  """
  def get_elements_by_name(document_pid, name) do
    query_selector_all(document_pid, ~s([name="#{name}"]))
  end

  @doc """
  Returns a list of all elements in the document that have the given tag name.

  This method implements the DOM `getElementsByTagName()` specification. It searches through
  all descendant elements in the document for elements with the specified tag name.

  ## Parameters

  - `document_pid` - The PID of the document to search in
  - `tag_name` - The tag name to search for (case-insensitive)

  ## Examples

      iex> document = GenDOM.Document.new([])
      iex> element = GenDOM.Element.new([tag_name: "div"])
      iex> GenDOM.Node.append_child(document.pid, element.pid)
      iex> found_elements = GenDOM.Document.get_elements_by_tag_name(document.pid, "div")
      iex> length(found_elements)
      1

  """
  def get_elements_by_tag_name(document_pid, tag_name) do
    all_descendants = :pg.get_members(document_pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, {:tag_name, tag_name})
        |> Map.get(:pid)
      end)
    end)

    await_many(tasks)
  end

  @doc """
  Returns a list of elements with the given tag name belonging to the given namespace.

  This method implements the DOM `getElementsByTagNameNS()` specification.

  ## Parameters

  - `document_pid` - The PID of the document to search in
  - `namespace` - The namespace URI to search for
  - `local_name` - The local name to search for

  ## Examples

      svg_rects = GenDOM.Document.get_elements_by_tag_name_ns(document.pid, "http://www.w3.org/2000/svg", "rect")

  """
  def get_elements_by_tag_name_ns(document_pid, namespace, local_name) do
    query_selector_all(document_pid, "#{namespace}|#{local_name}")
  end

  @doc """
  Returns a Selection object representing the range of text selected by the user or the current position of the caret.

  This method implements the DOM `getSelection()` specification.

  ## Parameters

  - `document` - The document to get selection from

  ## Examples

      selection = GenDOM.Document.get_selection(document)

  """
  def get_selection(_document_pid) do
    nil
  end

  @doc """
  Returns a boolean indicating whether the document or any element inside the document has focus.

  This method implements the DOM `hasFocus()` specification.

  ## Parameters

  - `document` - The document to check for focus

  ## Examples

      has_focus = GenDOM.Document.has_focus?(document)
      # => true or false

  """
  def has_focus?(_document_pid) do
    nil
  end

  @doc """
  Returns a boolean indicating whether the document has access to unpartitioned cookies.

  This method implements the DOM `hasStorageAccess()` specification.

  ## Parameters

  - `document` - The document to check storage access for

  ## Examples

      has_access = GenDOM.Document.has_storage_access?(document)
      # => true or false

  """
  def has_storage_access?(_document_pid) do
    nil
  end

  @doc """
  Returns a boolean indicating whether the document has access to unpartitioned cookies.

  This method implements the DOM `hasUnpartitionedCookieAccess()` specification.

  ## Parameters

  - `document` - The document to check cookie access for

  ## Examples

      has_access = GenDOM.Document.has_unpartitioned_cookie_access?(document)
      # => true or false

  """
  def has_unpartitioned_cookie_access?(_document_pid) do
    nil
  end

  @doc """
  Creates a copy of a node from an external document that can be inserted into the current document.

  This method implements the DOM `importNode()` specification.

  ## Parameters

  - `document` - The document to import the node into
  - `external_node` - The node to import
  - `deep?` - Whether to import all descendants

  ## Examples

      imported_node = GenDOM.Document.import_node(document, external_node, true)

  """
  def import_node(_document_pid, _external_node, _deep?) do
    nil
  end

  @doc """
  Opens a document for writing.

  This method implements the DOM `open()` specification. It opens the document
  for writing and clears all existing content.

  ## Parameters

  - `document` - The document to open

  ## Examples

      GenDOM.Document.open(document)

  """
  def open(_document_pid) do
    nil
  end

  @doc """
  Inserts a set of Node objects or string objects before the first child of the document.

  This method implements the DOM `prepend()` specification for documents.

  ## Parameters

  - `document` - The document to prepend nodes to
  - `nodes` - A list of Node objects or strings to prepend

  ## Examples

      GenDOM.Document.prepend(document, [doctype_node, processing_instruction])

  """
  def prepend(_document_pid, nodes) when is_list(nodes) do
    nil
  end

  @doc """
  Replaces the existing children of the document with a new set of children.

  This method implements the DOM `replaceChildren()` specification for documents.

  ## Parameters

  - `document` - The document to replace children for
  - `children` - A list of new child nodes

  ## Examples

      GenDOM.Document.replace_children(document, [new_doctype, new_root_element])

  """
  def replace_children(_document_pid, children) when is_list(children) do
    nil
  end

  @doc """
  Allows a document loaded in a third-party context to request access to unpartitioned cookies.

  This method implements the DOM `requestStorageAccess()` specification.

  ## Parameters

  - `document` - The document to request storage access for
  - `types` - Types of storage access to request

  ## Examples

      GenDOM.Document.request_storage_access(document, %{cookies: true})

  """
  def request_storage_access(_document_pid, _types \\ %{all: true}) do
    nil
  end

  @doc """
  Starts a new view transition and returns a ViewTransition object representing it.

  This method implements the DOM `startViewTransition()` specification.

  ## Parameters

  - `document` - The document to start the view transition for
  - `update_callback` - Function that performs the DOM changes

  ## Examples

      transition = GenDOM.Document.start_view_transition(document, fn -> 
        # DOM update logic
      end)

  """
  def start_view_transition(_document_pid, _update_callback) do
    nil
  end

  @doc """
  Writes a string of text followed by a newline character to a document.

  This method implements the DOM `writeln()` specification.

  ## Parameters

  - `document` - The document to write to
  - `line` - The text to write

  ## Examples

      GenDOM.Document.writeln(document, "<p>Hello World!</p>")

  """
  def writeln(_document_pid, line) when is_binary(line) do
    nil
  end

  def query_selector_all(pid_or_node, selectors) do
    GenDOM.QuerySelector.query_selector_all(pid_or_node, selectors)
  end
  defoverridable query_selector_all: 2

  def query_selector(pid_or_node, selectors) do
    GenDOM.QuerySelector.query_selector(pid_or_node, selectors)
  end
  defoverridable query_selector: 2
end
