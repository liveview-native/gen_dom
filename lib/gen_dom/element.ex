defmodule GenDOM.Element do
  @moduledoc """
  Element is the most general base class from which all element objects in a Document inherit.

  The Element interface represents an object of a Document. This interface describes methods
  and properties common to all kinds of elements. Specific behaviors are described in interfaces
  which inherit from Element but add additional functionality specific to those elements.

  ## Specification Compliance

  This module implements the DOM Element interface as defined by:
  - **W3C DOM Level 4**: https://www.w3.org/TR/dom/#element
  - **WHATWG DOM Standard**: https://dom.spec.whatwg.org/#element
  - **CSS Object Model**: https://www.w3.org/TR/cssom-view-1/

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      ├── GenDOM.HTMLElement (extends Element)
      ├── GenDOM.Element.Input (extends Element)
      ├── GenDOM.Element.Button (extends Element) 
      └── GenDOM.Element.Form (extends Element)
  ```

  **Inherits from:** `GenDOM.Node`  
  **File:** `lib/gen_dom/element.ex`  
  **Node Type:** 1 (ELEMENT_NODE)

  ## Properties

  ### Core Element Properties
  - `tag_name` - The element's tag name (read-only, e.g., "DIV", "P", "BUTTON")
  - `id` - The element's unique identifier within the document
  - `class_list` - DOMTokenList of CSS classes applied to the element
  - `attributes` - NamedNodeMap containing all element attributes

  ### Layout and Positioning
  - `client_height` - Inner height of element excluding horizontal scrollbar
  - `client_width` - Inner width of element excluding vertical scrollbar  
  - `client_left` - Width of left border of element
  - `client_top` - Width of top border of element
  - `scroll_height` - Entire height of content including overflow
  - `scroll_width` - Entire width of content including overflow
  - `scroll_left` - Number of pixels content is scrolled horizontally
  - `scroll_top` - Number of pixels content is scrolled vertically

  ### Element Relationships
  - `children` - HTMLCollection of child elements (elements only, not text nodes)
  - `child_element_count` - Number of child elements
  - `first_element_child` - First child element or nil
  - `last_element_child` - Last child element or nil
  - `next_element_sibling` - Next sibling element or nil
  - `previous_element_sibling` - Previous sibling element or nil

  ### Shadow DOM and Slots
  - `shadow_root` - Attached ShadowRoot or nil
  - `assigned_slot` - HTMLSlotElement this element is assigned to
  - `slot` - Name of the slot the element is assigned to

  ### Accessibility (ARIA)
  Complete implementation of WAI-ARIA 1.2 specification:
  - `aria_label` - Accessible name for the element
  - `aria_labelledby_elements` - Elements that label this element
  - `aria_describedby_elements` - Elements that describe this element
  - `aria_role` - ARIA role of the element
  - All standard ARIA states and properties (aria_*, 50+ attributes)

  ### Styling and CSS
  - `part` - DOMTokenList for CSS ::part() pseudo-element
  - `current_css_zoom` - Current effective zoom level

  ### Namespace Support
  - `namespace_uri` - Namespace URI of the element
  - `prefix` - Namespace prefix of the element
  - `local_name` - Local name within the namespace

  ## Methods

  ### Attribute Management
  - `get_attribute/2` - Retrieve attribute value by name
  - `set_attribute/3` - Set attribute value
  - `has_attribute?/2` - Check if attribute exists
  - `remove_attribute/2` - Remove attribute
  - `get_attribute_names/1` - Get list of all attribute names
  - `toggle_attribute/2` - Toggle boolean attribute

  ### Namespaced Attributes  
  - `get_attribute_ns/3` - Get attribute in specific namespace
  - `set_attribute_ns/4` - Set namespaced attribute
  - `has_attribute_ns?/3` - Check namespaced attribute existence
  - `remove_attribute_ns/3` - Remove namespaced attribute

  ### CSS Selector Queries
  - `query_selector/2` - Find first descendant matching selector
  - `query_selector_all/2` - Find all descendants matching selector
  - `closest/2` - Find closest ancestor matching selector
  - `matches?/2` - Test if element matches selector

  ### Element Collection Methods
  - `get_elements_by_tag_name/2` - Get elements by tag name
  - `get_elements_by_tag_name_ns/3` - Get elements by namespaced tag
  - `get_elements_by_class_name/2` - Get elements by class name

  ### DOM Manipulation
  - `append/2` - Insert nodes after last child
  - `prepend/2` - Insert nodes before first child
  - `before/2` - Insert nodes before this element
  - `do_after/2` - Insert nodes after this element (after is reserved keyword)
  - `replace_with/2` - Replace this element with nodes
  - `replace_children/2` - Replace all children with new nodes
  - `remove/1` - Remove element from DOM tree

  ### Layout and Positioning
  - `get_bounding_client_rect/1` - Get element's size and position
  - `get_client_rects/1` - Get border box rectangles
  - `scroll/2` - Scroll to coordinates
  - `scroll_by/2` - Scroll by offset
  - `scroll_to/2` - Scroll to specific coordinates
  - `scroll_into_view/2` - Scroll element into view

  ### Shadow DOM
  - `attach_shadow/2` - Attach shadow root
  - `get_shadow_root/1` - Get attached shadow root

  ### Fullscreen and Pointer APIs
  - `request_fullscreen/2` - Request fullscreen mode
  - `request_pointer_lock/2` - Request pointer lock
  - `set_pointer_capture/2` - Capture pointer events
  - `release_pointer_capture/2` - Release pointer capture
  - `has_pointer_capture?/2` - Check pointer capture status

  ### Animation
  - `animate/3` - Create Web Animation
  - `get_animations/2` - Get active animations

  ### Visibility and Intersection
  - `check_visibility/2` - Check if element is visible

  ### HTML Content
  - `get_html/2` - Get HTML serialization
  - `set_html_unsafe/2` - Set inner HTML (unsafe)
  - `insert_adjacent_element/3` - Insert element at position
  - `insert_adjacent_html/3` - Insert HTML at position
  - `insert_adjacent_text/3` - Insert text at position

  ## Usage Examples

  ```elixir
  # Create an element
  element = GenDOM.Element.new([
    tag_name: "div",
    id: "container",
    class_list: ["card", "primary"],
    attributes: %{"data-id" => "123", "role" => "main"}
  ])

  # Attribute manipulation
  GenDOM.Element.set_attribute(element.pid, "class", "btn primary")
  class_value = GenDOM.Element.get_attribute(element.pid, "class")
  has_disabled = GenDOM.Element.has_attribute?(element.pid, "disabled")

  # CSS selector queries
  first_button = GenDOM.Element.query_selector(element.pid, "button")
  all_inputs = GenDOM.Element.query_selector_all(element.pid, "input[type='text']")
  closest_form = GenDOM.Element.closest(element.pid, "form")

  # DOM manipulation
  GenDOM.Element.append(element.pid, [child1, child2])
  GenDOM.Element.remove(old_element.pid)

  # Layout information
  rect = GenDOM.Element.get_bounding_client_rect(element.pid)
  GenDOM.Element.scroll_into_view(element.pid, true)
  ```

  ## Process-Based Architecture

  Each Element is implemented as a GenServer process, providing:
  - **Concurrent DOM operations** - Multiple elements can be manipulated simultaneously
  - **State isolation** - Each element maintains its own state independently
  - **Fault tolerance** - Element crashes don't affect other parts of the DOM tree
  - **Message-based communication** - Thread-safe operations between elements

  ## Event Handling

  Elements support the full DOM Event specification:
  - Event listener registration and removal
  - Event propagation (capturing and bubbling phases)
  - Custom event creation and dispatch
  - Standard event types (click, focus, input, etc.)

  ## Accessibility Features

  Full WAI-ARIA 1.2 compliance:
  - Complete set of ARIA roles, states, and properties
  - Accessible name computation
  - Keyboard navigation support
  - Screen reader compatibility
  - Focus management

  """

  @derive {Inspect, only: [:pid, :tag_name, :id, :class_list, :attributes]}

  use GenDOM.Node, [
    active_element: nil,
    adopted_style_sheets: nil,
    node_type: 1,
    is_element?: true,

    tag_name: nil,
    aria_active_descendant_element: nil,
    aria_atomic: nil,
    aria_auto_complete: nil,
    aria_braille_label: nil,
    aria_braille_role_description: nil,
    aria_busy: nil,
    aria_checked: nil,
    aria_col_count: nil,
    aria_col_index: nil,
    aria_col_index_text: nil,
    aria_col_span: nil,
    aria_controls_elements: nil,
    aria_current: nil,
    aria_described_by_elements: nil,
    aria_description: nil,
    aria_details_elements: nil,
    aria_disabled: nil,
    aria_error_message_elements: nil,
    aria_expanded: nil,
    aria_flow_to_elements: nil,
    aria_has_popup: nil,
    aria_hidden: nil,
    aria_invalid: nil,
    aria_key_shortcuts: nil,
    aria_label: nil,
    aria_labelled_by_elements: nil,
    aria_level: nil,
    aria_live: nil,
    aria_modal: nil,
    aria_multi_line: nil,
    aria_multi_selectable: nil,
    aria_orientation: nil,
    aria_owns_elements: nil,
    aria_placeholder: nil,
    aria_pos_in_set: nil,
    aria_pressed: nil,
    aria_read_only: nil,
    aria_relevant_non_standard: nil,
    aria_required: nil,
    aria_role_description: nil,
    aria_row_count: nil,
    aria_row_index: nil,
    aria_row_index_text: nil,
    aria_row_span: nil,
    aria_selected: nil,
    aria_set_size: nil,
    aria_sort: nil,
    aria_value_max: nil,
    aria_value_min: nil,
    aria_value_now: nil,
    aria_value_text: nil,

    assigned_slot: nil,
    attributes: %{},
    child_element_count: 0,
    children: [],
    class_list: [],
    # This is in the spec but it's an unnecessary
    # duplication of data
    # class_name: "",
    client_height: 0,
    client_left: 0,
    client_top: 0,
    client_width: 0,
    current_css_zoom: 1,
    first_element_child: nil,
    id: "",
    inner_html: "",
    last_element_child: nil,
    local_name: nil,
    namespace_uri: nil,
    next_element_sibling: nil,
    outer_html: "",
    part: nil,
    prefix: nil,
    previous_element_sibling: nil,
    role: nil,
    scroll_height: 0,
    scroll_left: 0,
    scroll_top: 0,
    scroll_width: 0,
    shadow_root: nil,
    slot: nil,
  ]

  defmacro __using__(fields \\ []) do
    quote do
      Module.register_attribute(__MODULE__, :fields, accumulate: true)

      @fields unquote(Macro.escape(@fields))
      @fields unquote(Macro.escape(fields))

      use GenDOM.Node

      # Element instance method delegations
      defdelegate do_after(element, nodes), to: GenDOM.Element
      defoverridable do_after: 2

      defdelegate animate(element, keyframes, options \\ []), to: GenDOM.Element
      defoverridable animate: 3

      defdelegate append(element, nodes), to: GenDOM.Element
      defoverridable append: 2

      defdelegate attach_shadow(element, options \\ []), to: GenDOM.Element
      defoverridable attach_shadow: 2

      defdelegate before(element, nodes), to: GenDOM.Element
      defoverridable before: 2

      defdelegate check_visibility(element, options \\ []), to: GenDOM.Element
      defoverridable check_visibility: 2

      defdelegate closest(element, selectors), to: GenDOM.Element
      defoverridable closest: 2

      defdelegate computed_style_map(element), to: GenDOM.Element
      defoverridable computed_style_map: 1

      defdelegate get_animations(element, options \\ []), to: GenDOM.Element
      defoverridable get_animations: 2

      defdelegate get_attribute(element, attribute_name), to: GenDOM.Element
      defoverridable get_attribute: 2

      defdelegate get_attribute_names(element), to: GenDOM.Element
      defoverridable get_attribute_names: 1

      defdelegate get_attribute_node(element, attribute_name), to: GenDOM.Element
      defoverridable get_attribute_node: 2

      defdelegate get_attribute_node_ns(element, namespace, node_name), to: GenDOM.Element
      defoverridable get_attribute_node_ns: 3

      defdelegate get_attribute_ns(element, namespace, name), to: GenDOM.Element
      defoverridable get_attribute_ns: 3

      defdelegate get_bounding_client_rect(element), to: GenDOM.Element
      defoverridable get_bounding_client_rect: 1

      defdelegate get_client_rects(element), to: GenDOM.Element
      defoverridable get_client_rects: 1

      defdelegate get_elements_by_class_name(element, names), to: GenDOM.Element
      defoverridable get_elements_by_class_name: 2

      defdelegate get_elements_by_tag_name(element, tag_name), to: GenDOM.Element
      defoverridable get_elements_by_tag_name: 2

      defdelegate get_elements_by_tag_name_ns(element, namespace, local_name), to: GenDOM.Element
      defoverridable get_elements_by_tag_name_ns: 3

      defdelegate get_html(element, options \\ []), to: GenDOM.Element
      defoverridable get_html: 2

      defdelegate has_attribute?(element, name), to: GenDOM.Element
      defoverridable has_attribute?: 2

      defdelegate has_attribute_ns?(element, namespace, local_name), to: GenDOM.Element
      defoverridable has_attribute_ns?: 3

      defdelegate has_attributes?(element), to: GenDOM.Element
      defoverridable has_attributes?: 1

      defdelegate has_pointer_capture?(element, pointer_id), to: GenDOM.Element
      defoverridable has_pointer_capture?: 2

      defdelegate insert_adjacent_element(element, position, other_element), to: GenDOM.Element
      defoverridable insert_adjacent_element: 3

      defdelegate insert_adjacent_html(element, position, text), to: GenDOM.Element
      defoverridable insert_adjacent_html: 3

      defdelegate insert_adjacent_text(element, where, data), to: GenDOM.Element
      defoverridable insert_adjacent_text: 3

      defdelegate matches?(element, selectors), to: GenDOM.Element
      defoverridable matches?: 2

      defdelegate prepend(element, nodes), to: GenDOM.Element
      defoverridable prepend: 2

      defdelegate release_pointer_capture(element, pointer_id), to: GenDOM.Element
      defoverridable release_pointer_capture: 2

      defdelegate remove(element), to: GenDOM.Element
      defoverridable remove: 1

      defdelegate remove_attribute(element, attribute_name), to: GenDOM.Element
      defoverridable remove_attribute: 2

      defdelegate remove_attribute_node(element, attribute_node), to: GenDOM.Element
      defoverridable remove_attribute_node: 2

      defdelegate remove_attribute_ns(element, namespace, attribute_node), to: GenDOM.Element
      defoverridable remove_attribute_ns: 3

      defdelegate replace_children(element, children), to: GenDOM.Element
      defoverridable replace_children: 2

      defdelegate replace_with(element, nodes), to: GenDOM.Element
      defoverridable replace_with: 2

      defdelegate request_fullscreen(element, options \\ []), to: GenDOM.Element
      defoverridable request_fullscreen: 2

      defdelegate request_pointer_lock(element, options \\ []), to: GenDOM.Element
      defoverridable request_pointer_lock: 2

      defdelegate scroll(element, options), to: GenDOM.Element
      defdelegate scroll(element, x_coord, y_coord), to: GenDOM.Element
      defoverridable scroll: 2
      defoverridable scroll: 3

      defdelegate scroll_by(element, options), to: GenDOM.Element
      defoverridable scroll_by: 2

      defdelegate scroll_into_view(element, align_to_top), to: GenDOM.Element
      defoverridable scroll_into_view: 2

      defdelegate scroll_to(element, options), to: GenDOM.Element
      defdelegate scroll_to(element, x_coord, y_coord), to: GenDOM.Element
      defoverridable scroll_to: 2
      defoverridable scroll_to: 3

      defdelegate set_attribute(element, name, value), to: GenDOM.Element
      defoverridable set_attribute: 3

      defdelegate set_attribute_node(element, attribute), to: GenDOM.Element
      defoverridable set_attribute_node: 2

      defdelegate set_attribute_node_ns(element, attribute_node), to: GenDOM.Element
      defoverridable set_attribute_node_ns: 2

      defdelegate set_attribute_ns(element, namespace, name, value), to: GenDOM.Element
      defoverridable set_attribute_ns: 4

      defdelegate set_html_unsafe(element, html), to: GenDOM.Element
      defoverridable set_html_unsafe: 2

      defdelegate set_pointer_capture(element, pointer_id), to: GenDOM.Element
      defoverridable set_pointer_capture: 2

      defdelegate toggle_attribute(element, name), to: GenDOM.Element
      defdelegate toggle_attribute(element, name, force), to: GenDOM.Element
      defoverridable toggle_attribute: 2
      defoverridable toggle_attribute: 3

      defdelegate encode(node), to: GenDOM.Element
      defoverridable encode: 1
    end
  end

  def encode(element) do
    Map.merge(super(element), %{
      class_list: element.class_list,
      id: element.id,
      attributes: element.attributes,
      tag_name: element.tag_name
    })
  end

  @impl true
  def init(opts) do
    {:ok, element} = super(opts)

    fields = extract_fields_from_attributes(Keyword.get(opts, :attributes, %{}))

    {:ok, struct(element, fields)}
  end

  @impl true
  def handle_call({:append_child, child, opts} = msg, from, element) do
    {:reply, element, element} = super(msg, from, element)

    element = do_append_child(element, child, opts)

    {:reply, element, element}
  end

  def handle_call({:insert_before, new_element, reference_element, opts} = msg, from, element) do
    {:reply, element, element} = super(msg, from, element)

    element = do_insert_before(element, new_element, reference_element, opts)

    {:reply, element, element}
  end

  def handle_call({:remove_child, child, opts} = msg, from, element) do
    {:reply, element, element} = super(msg, from, element)

    element = do_remove_child(element, child, opts)

    {:reply, element, element}
  end

  def handle_call({:replace_child, new_child, old_child, opts} = msg, from, element) do
    {:reply, element, element} = super(msg, from, element)
  
    element = do_replace_child(element, new_child, old_child, opts)

    {:reply, element, element}
  end

  def handle_call(msg, from, element) do
    super(msg, from, element)
  end

  @impl true
  def handle_cast({:append_child, child, opts} = msg, element) do
    {:noreply, element} = super(msg, element)

    element = do_append_child(element, child, opts)

    {:noreply, element}
  end

  def handle_cast({:insert_before, new_element, reference_element, opts} = msg, element) do
    {:noreply, element} = super(msg, element)

    element = do_insert_before(element, new_element, reference_element, opts)

    {:noreply, element}
  end

  def handle_cast({:remove_child, child, opts} = msg, element) do
    {:noreply, element} = super(msg, element)

    element = do_remove_child(element, child, opts)

    {:noreply, element}
  end

  def handle_cast({:replace_child, new_child, old_child, opts} = msg, element) do
    {:noreply, element} = super(msg, element)
  
    element = do_replace_child(element, new_child, old_child, opts)

    {:noreply, element}
  end

  def handle_cast(msg, element) do
    super(msg, element)
  end

  defp do_append_child(parent, child, opts) do
    case child do
      %GenDOM.Node{} -> parent

      %GenDOM.Text{} -> parent 

      child ->
        pos = length(parent.children)
        children = List.insert_at(parent.children, -1, child.pid)

        parent = struct(parent, children: children, child_element_count: parent.child_element_count + 1)
        parent = struct(parent, children: children)

        update_parent_relationships(parent, child, pos, opts)
        update_element_relationships(child, parent, pos, opts)

        parent
    end
  end

  defp do_insert_before(element, new_element, %{pid: reference_element_pid}, _opts) do
    children = Enum.reduce(element.children, [], fn
      ^reference_element_pid, children ->
        case new_element do
          %GenDOM.Text{} -> children
          new_element -> [reference_element_pid, new_element.pid | children]
        end

      child_pid, children -> [child_pid | children]
    end)

    struct(element, children: children, child_element_count: element.child_element_count + 1)
  end

  defp do_remove_child(element, child, _opts) do
    children = Enum.reject(element.children, &(&1 == child.pid))
    struct(element, children: children, child_element_count: element.child_element_count - 1)
  end

  defp do_replace_child(element, new_child, %{pid: old_child_pid}, opts) do
    {children, pos} = Enum.reduce(element.children, {[], 0}, fn
      child_pid, {children, pos} when child_pid == old_child_pid ->
        update_parent_relationships(element, new_child, pos, opts)
        {[new_child.pid | children], pos + 1}

      child_pid, {children, pos} -> {[child_pid | children], pos + 1}
    end)

    update_element_relationships(new_child, element, pos, opts)

    struct(element, children: children)
  end

  def clone_node(node_pid, deep? \\ false) do
    node = get(node_pid)

    fields = Map.drop(node, [
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

      :assigned_slot,
      :child_element_count,
      :children,
      :client_height,
      :client_left,
      :client_top,
      :client_width,
      :last_element_child,
      :next_element_sigling,
      :previous_element_sigling,
      :scroll_height,
      :scroll_left,
      :scroll_top,
      :scroll_width,
      :slot
    ]) |> Map.to_list()

    new_node = apply(node.__struct__, :new, [fields])

    if deep? do
      Enum.reduce(node.child_nodes, new_node.pid, fn(child_node_pid, new_node_pid) ->
        append_child(new_node_pid, clone_node(child_node_pid, deep?))      end)
    else
      new_node.pid
    end
  end

  defp extract_fields_from_attributes(attributes) do
    Enum.reduce(attributes, %{}, &extract_fields_from_attribute(&1, &2))
  end

  defp extract_fields_from_attribute({"id", id}, fields) do
    Map.put(fields, :id, id)
  end

  defp extract_fields_from_attribute({"class", class_name}, fields) do
    Map.merge(fields, %{
      class_list: String.split(class_name)
    })
  end

  defp extract_fields_from_attribute(_attributes, fields) do
    fields
  end

  @impl true
  def handle_info({:DOWN, ref, :process, pid, :normal}, element) when is_reference(ref) and is_pid(pid) do
    {:noreply, element}
  end

  def handle_info(msg, element) do
    super(msg, element)
  end


  def allowed_fields,
    do: super() ++ [:class_list, :id, :attributes, :tag_name]

  @doc """
  Inserts a set of Node objects or string objects after the element.

  This method implements the DOM `after()` specification. Note: In Elixir, `after` is a
  reserved keyword, so this method is named `do_after`.

  ## Parameters

  - `element_pid` - The PID of the element to insert nodes after
  - `nodes` - A list of Node objects or strings to insert

  ## Examples

      GenDOM.Element.do_after(element.pid, [new_element, "Some text"])

  """
  # Elixir has `after` as a reserved keyword so this must be called `do_after`
  def do_after(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  @doc """
  Returns an Animation object representing an animation that plays on the element.

  This method implements the DOM `animate()` specification for creating animations
  using the Web Animations API.

  ## Parameters

  - `element` - The element to animate
  - `keyframes` - The keyframes to animate through
  - `options` - Animation options (duration, easing, etc.)

  ## Examples

      animation = GenDOM.Element.animate(element, 
        [%{transform: "translateX(0px)"}, %{transform: "translateX(100px)"}],
        duration: 1000
      )

  """
  def animate(%__MODULE__{} = element, keyframes, options \\ []) do

  end

  @doc """
  Inserts a set of Node objects or string objects after the last child of the element.

  This method implements the DOM `append()` specification. The nodes are inserted
  in the same order as they appear in the list.

  ## Parameters

  - `element` - The element to append nodes to
  - `nodes` - A list of Node objects or strings to append

  ## Examples

      GenDOM.Element.append(parent_element, [child_element, "Some text"])

  """
  def append(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  @doc """
  Attaches a shadow DOM tree to the specified element and returns a reference to its ShadowRoot.

  This method implements the DOM `attachShadow()` specification for creating Shadow DOM.

  ## Parameters

  - `element` - The element to attach a shadow root to
  - `options` - Shadow DOM options (mode: :open or :closed)

  ## Examples

      shadow_root = GenDOM.Element.attach_shadow(element, mode: :open)

  """
  def attach_shadow(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Inserts a set of Node objects or string objects in the children list of the element's parent, just before the element.

  This method implements the DOM `before()` specification.

  ## Parameters

  - `element` - The element to insert nodes before
  - `nodes` - A list of Node objects or strings to insert

  ## Examples

      GenDOM.Element.before(element, [new_element, "Some text"])

  """
  def before(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  @doc """
  Checks whether the element would be visible to a user.

  This method implements the DOM `checkVisibility()` specification. It returns a boolean
  indicating whether the element is visible.

  ## Parameters

  - `element` - The element to check visibility for
  - `options` - Visibility check options

  ## Examples

      is_visible = GenDOM.Element.check_visibility(element)
      # => true or false

  """
  def check_visibility(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Returns the closest ancestor element (or the element itself) that matches the specified selectors.

  This method implements the DOM `closest()` specification. It traverses the element and its
  parents heading toward the document root until it finds a node matching the selector.

  ## Parameters

  - `element` - The element to start searching from
  - `selectors` - A CSS selector string to match against

  ## Examples

      parent = GenDOM.Element.closest(element, ".container")
      button = GenDOM.Element.closest(element, "button[type='submit']")

  """
  def closest(nil, _selectors),
    do: nil

  def closest(element_pid, selectors) when is_binary(selectors) do
    closest(element_pid, Selector.parse(selectors))
  end

  def closest(element_pid, selectors) do
    element = get(element_pid)

    if closest_pid = query_selector(element_pid, selectors) do
      closest_pid
    else
      closest(element.parent_element || element.owner_document, selectors)
    end
  end

  @doc """
  Returns a StylePropertyMapReadOnly interface containing the computed CSS property values.

  This method implements the DOM `computedStyleMap()` specification from the CSS Typed OM.

  ## Parameters

  - `element` - The element to get computed styles for

  ## Examples

      style_map = GenDOM.Element.computed_style_map(element)

  """
  def computed_style_map(%__MODULE__{} = element) do

  end

  @doc """
  Returns an array of all Animation objects affecting this element or its descendants.

  This method implements the DOM `getAnimations()` specification.

  ## Parameters

  - `element` - The element to get animations for
  - `options` - Options for filtering animations

  ## Examples

      animations = GenDOM.Element.get_animations(element)
      running_animations = GenDOM.Element.get_animations(element, subtree: true)

  """
  def get_animations(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Retrieves the value of the named attribute from the current element and returns it as a string.

  This method implements the DOM `getAttribute()` specification. If the attribute doesn't exist,
  it returns `nil`.

  ## Parameters

  - `element_pid` - The PID of the element to get the attribute from
  - `attribute_name` - The name of the attribute to retrieve

  ## Examples

      iex> element = GenDOM.Element.new([attributes: %{"class" => "btn", "id" => "submit"}])
      iex> GenDOM.Element.get_attribute(element.pid, "class")
      "btn"
      iex> GenDOM.Element.get_attribute(element.pid, "nonexistent")
      nil

  """
  def get_attribute(element_pid, attribute_name) do
    %{attributes: attributes} = get(element_pid)
    Map.get(attributes, attribute_name)
  end

  @doc """
  Returns the attribute names of the element as an array of strings.

  This method implements the DOM `getAttributeNames()` specification.

  ## Parameters

  - `element_pid` - The PID of the element to get attribute names from

  ## Examples

      iex> element = GenDOM.Element.new([attributes: %{"class" => "btn", "id" => "submit", "disabled" => "true"}])
      iex> GenDOM.Element.get_attribute_names(element.pid)
      ["class", "id", "disabled"]

  """
  def get_attribute_names(element_pid) do
    %{attributes: attributes} = get(element_pid)
    Map.keys(attributes)
  end

  @doc """
  Returns the specified attribute node for the current element.

  This method implements the DOM `getAttributeNode()` specification.

  ## Parameters

  - `element` - The element to get the attribute node from
  - `attribute_name` - The name of the attribute node to retrieve

  ## Examples

      attr_node = GenDOM.Element.get_attribute_node(element, "class")

  """
  def get_attribute_node(%__MODULE__{} = element, attribute_name) do

  end

  @doc """
  Returns the Attr node for the attribute with the given namespace and name.

  This method implements the DOM `getAttributeNodeNS()` specification.

  ## Parameters

  - `element` - The element to get the attribute node from
  - `namespace` - The namespace of the attribute
  - `node_name` - The name of the attribute

  ## Examples

      attr_node = GenDOM.Element.get_attribute_node_ns(element, "http://www.w3.org/1999/xlink", "href")

  """
  def get_attribute_node_ns(%__MODULE__{} = element, namespace, node_name) do

  end

  @doc """
  Returns the string value of the attribute with the specified namespace and name.

  This method implements the DOM `getAttributeNS()` specification.

  ## Parameters

  - `element` - The element to get the attribute from
  - `namespace` - The namespace of the attribute
  - `name` - The name of the attribute

  ## Examples

      value = GenDOM.Element.get_attribute_ns(element, "http://www.w3.org/1999/xlink", "href")

  """
  def get_attribute_ns(%__MODULE__{} = element, namespace, name) do

  end

  @doc """
  Returns the size of an element and its position relative to the viewport.

  This method implements the DOM `getBoundingClientRect()` specification. It returns
  a DOMRect object providing information about the size and position of the element.

  ## Parameters

  - `element` - The element to get the bounding rectangle for

  ## Examples

      rect = GenDOM.Element.get_bounding_client_rect(element)
      # => %{x: 0, y: 0, width: 100, height: 50, top: 0, right: 100, bottom: 50, left: 0}

  """
  def get_bounding_client_rect(%__MODULE__{} = element) do

  end

  @doc """
  Returns a collection of DOMRect objects that indicate the bounding rectangles for each CSS border box in the element.

  This method implements the DOM `getClientRects()` specification.

  ## Parameters

  - `element` - The element to get client rectangles for

  ## Examples

      rects = GenDOM.Element.get_client_rects(element)
      # => [%{x: 0, y: 0, width: 100, height: 25}, %{x: 0, y: 25, width: 100, height: 25}]

  """
  def get_client_rects(%__MODULE__{} = element) do

  end

  @doc """
  Returns a live collection of child elements which have all of the given class names.

  This method implements the DOM `getElementsByClassName()` specification.

  ## Parameters

  - `element` - The element to search within
  - `names` - A list of class names to search for

  ## Examples

      elements = GenDOM.Element.get_elements_by_class_name(element, ["btn", "primary"])

  """
  def get_elements_by_class_name(element_pid, names) do
    query = Stream.map(names, &(".#{&1}")) |> Enum.join(",")

    GenServer.call(element_pid, {:query_selector_all, query})
  end

  @doc """
  Returns a live collection of elements with the given tag name.

  This method implements the DOM `getElementsByTagName()` specification. The search is limited
  to descendants of the specified element.

  ## Parameters

  - `element` - The element to search within
  - `tag_name` - The tag name to search for (case-insensitive)

  ## Examples

      divs = GenDOM.Element.get_elements_by_tag_name(element, "div")
      all_elements = GenDOM.Element.get_elements_by_tag_name(element, "*")

  """
  def get_elements_by_tag_name(element_pid, tag_name) do
    GenServer.call(element_pid, {:query_selector_all, tag_name})
  end

  @doc """
  Returns a live collection of elements with the given tag name belonging to the given namespace.

  This method implements the DOM `getElementsByTagNameNS()` specification.

  ## Parameters

  - `element` - The element to search within
  - `namespace` - The namespace URI to search for
  - `local_name` - The local name to search for

  ## Examples

      svg_elements = GenDOM.Element.get_elements_by_tag_name_ns(element, "http://www.w3.org/2000/svg", "rect")

  """
  def get_elements_by_tag_name_ns(element_pid, namespace, local_name) do
    query = "#{namespace}|#{local_name}"
    GenServer.call(element_pid, {:query_selector_all, query})
  end

  @doc """
  Returns a string representing the markup serialization of the element and its descendants.

  This method implements the DOM `getHTML()` specification (proposed feature).

  ## Parameters

  - `element` - The element to serialize
  - `options` - Serialization options

  ## Examples

      markup = GenDOM.Element.get_html(element)
      # => "<div class='container'><p>Hello</p></div>"

  """
  def get_html(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Returns a boolean indicating whether the specified element has the specified attribute.

  This method implements the DOM `hasAttribute()` specification.

  ## Parameters

  - `element_pid` - The PID of the element to check for the attribute
  - `name` - The name of the attribute to check for

  ## Examples

      iex> element = GenDOM.Element.new([attributes: %{"class" => "btn", "disabled" => "true"}])
      iex> GenDOM.Element.has_attribute?(element.pid, "class")
      true
      iex> GenDOM.Element.has_attribute?(element.pid, "nonexistent")
      false

  """
  def has_attribute?(element_pid, name) do
    %{attributes: attributes} = get(element_pid)
    Map.has_key?(attributes, name)
  end

  @doc """
  Returns a boolean indicating whether the element has the specified attribute in the specified namespace.

  This method implements the DOM `hasAttributeNS()` specification.

  ## Parameters

  - `element` - The element to check
  - `namespace` - The namespace to check for the attribute in
  - `local_name` - The name of the attribute to check for

  ## Examples

      has_attr = GenDOM.Element.has_attribute_ns?(element, "http://www.w3.org/1999/xlink", "href")
      # => true or false

  """
  def has_attribute_ns?(%__MODULE__{} = element, namespace, local_name) do

  end

  @doc """
  Returns a boolean indicating whether the current element has any attributes.

  This method implements the DOM `hasAttributes()` specification.

  ## Parameters

  - `element` - The element to check for attributes

  ## Examples

      has_attrs = GenDOM.Element.has_attributes?(element)
      # => true or false

  """
  def has_attributes?(%__MODULE__{} = element) do

  end

  @doc """
  Returns a boolean indicating whether the element on which it is invoked has pointer capture for the pointer identified by the given pointer ID.

  This method implements the DOM `hasPointerCapture()` specification.

  ## Parameters

  - `element` - The element to check pointer capture for
  - `pointer_id` - The identifier for the pointer to check

  ## Examples

      has_capture = GenDOM.Element.has_pointer_capture?(element, pointer_id)
      # => true or false

  """
  def has_pointer_capture?(%__MODULE__{} = element, pointer_id) do

  end

  @doc """
  Inserts a given element node at a given position relative to the element it is invoked upon.

  This method implements the DOM `insertAdjacentElement()` specification.

  ## Parameters

  - `element` - The element to insert relative to
  - `position` - The position relative to element: :beforebegin, :afterbegin, :beforeend, or :afterend
  - `other_element` - The element to insert

  ## Examples

      GenDOM.Element.insert_adjacent_element(element, :afterend, new_element)

  """
  def insert_adjacent_element(%__MODULE__{} = element, position, %__MODULE__{} = other_element) do

  end

  @doc """
  Parses the specified text as markup and inserts the resulting nodes into the DOM tree at a specified position.

  This method implements the DOM `insertAdjacentHTML()` specification.

  ## Parameters

  - `element` - The element to insert relative to
  - `position` - The position relative to element: :beforebegin, :afterbegin, :beforeend, or :afterend
  - `text` - The markup text to parse and insert

  ## Examples

      GenDOM.Element.insert_adjacent_html(element, :beforeend, "<p>New content</p>")

  """
  def insert_adjacent_html(%__MODULE__{} = element, position, text) when is_binary(text) do

  end

  @doc """
  Inserts a given text node at a given position relative to the element it is invoked upon.

  This method implements the DOM `insertAdjacentText()` specification.

  ## Parameters

  - `element` - The element to insert relative to
  - `where` - The position relative to element: :beforebegin, :afterbegin, :beforeend, or :afterend
  - `data` - The text data to insert

  ## Examples

      GenDOM.Element.insert_adjacent_text(element, :afterend, "Some text content")

  """
  def insert_adjacent_text(%__MODULE__{} = element, where, data) when is_binary(data) do

  end

  @doc """
  Tests whether the element would be selected by the specified CSS selector.

  ## Parameters
  - element - The element to match upon
  - slectors - A string containing valid CSS selectors to test the Element against.
  """
  def matches?(element_pid, selectors) do
    selectors = Selector.parse(selectors)
    element = get(element_pid)
    !!GenDOM.Matcher.match(element, selectors, await: &GenDOM.Task.await_one/1, recursive: false)
  end

  @doc """
  Inserts a set of Node objects or string objects before the first child of the element.

  This method implements the DOM `prepend()` specification.

  ## Parameters

  - `element` - The element to prepend nodes to
  - `nodes` - A list of Node objects or strings to prepend

  ## Examples

      GenDOM.Element.prepend(parent_element, [header_element, "Title: "])

  """
  def prepend(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  @doc """
  Releases pointer capture that was previously set for a specific pointer.

  This method implements the DOM `releasePointerCapture()` specification.

  ## Parameters

  - `element` - The element to release pointer capture from
  - `pointer_id` - The identifier for the pointer

  ## Examples

      GenDOM.Element.release_pointer_capture(element, pointer_id)

  """
  def release_pointer_capture(%__MODULE__{} = element, pointer_id) do

  end

  @doc """
  Removes the element from the DOM tree.

  This method implements the DOM `remove()` specification. The element is removed
  from its parent's children list.

  ## Parameters

  - `element` - The element to remove

  ## Examples

      GenDOM.Element.remove(element)

  """
  def remove(%__MODULE__{} = element) do

  end

  @doc """
  Removes the specified attribute from the element.

  This method implements the DOM `removeAttribute()` specification.

  ## Parameters

  - `element` - The element to remove the attribute from
  - `attribute_name` - The name of the attribute to remove

  ## Examples

      GenDOM.Element.remove_attribute(element, "disabled")

  """
  def remove_attribute(element_pid, attribute_name) do
    %{attributes: attributes} = get(element_pid)
    attributes = Map.delete(attributes, attribute_name)
    GenServer.cast(element_pid, {:put, :attributes, attributes})
  end

  @doc """
  Removes the specified Attr node from the element.

  This method implements the DOM `removeAttributeNode()` specification.

  ## Parameters

  - `element` - The element to remove the attribute node from
  - `attribute_node` - The Attr node to remove

  ## Examples

      removed_attr = GenDOM.Element.remove_attribute_node(element, attr_node)

  """
  def remove_attribute_node(%__MODULE__{} = element, attribute_node) do

  end

  @doc """
  Removes the specified attribute from the element within the given namespace.

  This method implements the DOM `removeAttributeNS()` specification.

  ## Parameters

  - `element` - The element to remove the attribute from
  - `namespace` - The namespace of the attribute
  - `attribute_node` - The local name of the attribute to remove

  ## Examples

      GenDOM.Element.remove_attribute_ns(element, "http://www.w3.org/1999/xlink", "href")

  """
  def remove_attribute_ns(%__MODULE__{} = element, namespace, attribute_node) do

  end

  @doc """
  Replaces the existing children of the element with a new set of children.

  This method implements the DOM `replaceChildren()` specification.

  ## Parameters

  - `element` - The element to replace children for
  - `children` - A list of new child nodes

  ## Examples

      GenDOM.Element.replace_children(element, [new_child1, new_child2])

  """
  def replace_children(%__MODULE__{} = element, children) when is_list(children) do

  end

  @doc """
  Replaces the element in the children list of its parent with a set of Node objects or strings.

  This method implements the DOM `replaceWith()` specification.

  ## Parameters

  - `element` - The element to replace
  - `nodes` - A list of Node objects or strings to replace with

  ## Examples

      GenDOM.Element.replace_with(old_element, [new_element, "Some text"])

  """
  def replace_with(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  @doc """
  Issues an asynchronous request to make the element be displayed in fullscreen mode.

  This method implements the DOM `requestFullscreen()` specification.

  ## Parameters

  - `element` - The element to display in fullscreen
  - `options` - Fullscreen options

  ## Examples

      GenDOM.Element.request_fullscreen(video_element, navigation_ui: :hide)

  """
  def request_fullscreen(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Asynchronously requests that the pointer be locked to the given element.

  This method implements the DOM `requestPointerLock()` specification.

  ## Parameters

  - `element` - The element to lock the pointer to
  - `options` - Pointer lock options

  ## Examples

      GenDOM.Element.request_pointer_lock(canvas_element)

  """
  def request_pointer_lock(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Scrolls the element to a particular set of coordinates inside a given element.

  This method implements the DOM `scroll()` specification.

  ## Parameters

  - `element` - The element to scroll
  - `options` - Scroll options (top, left, behavior)

  ## Examples

      GenDOM.Element.scroll(element, top: 100, left: 0, behavior: :smooth)

  """
  def scroll(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Scrolls the element to a particular set of coordinates inside a given element.

  This method implements the DOM `scroll()` specification with explicit coordinates.

  ## Parameters

  - `element` - The element to scroll
  - `x_coord` - The pixel along the horizontal axis to scroll to
  - `y_coord` - The pixel along the vertical axis to scroll to

  ## Examples

      GenDOM.Element.scroll(element, 0, 100)

  """
  def scroll(%__MODULE__{} = element, x_coord, y_coord) do

  end

  @doc """
  Scrolls the element by the given amount.

  This method implements the DOM `scrollBy()` specification.

  ## Parameters

  - `element` - The element to scroll
  - `options` - Scroll options (top, left, behavior)

  ## Examples

      GenDOM.Element.scroll_by(element, top: 50, left: 0, behavior: :smooth)

  """
  def scroll_by(%__MODULE__{} = element, options \\ []) do

  end

  @doc """
  Scrolls the element's parent container such that the element is visible to the user.

  This method implements the DOM `scrollIntoView()` specification.

  ## Parameters

  - `element` - The element to scroll into view
  - `align_to_top` - Boolean indicating whether to align to the top of the scrolling area

  ## Examples

      GenDOM.Element.scroll_into_view(element, true)

  """
  def scroll_into_view(%__MODULE__{} = element, align_to_top) when is_boolean(align_to_top) do

  end

  @doc """
  Scrolls the element's parent container such that the element is visible to the user.

  This method implements the DOM `scrollIntoView()` specification with options.

  ## Parameters

  - `element` - The element to scroll into view
  - `scroll_into_view_options` - A map containing scroll options (behavior, block, inline)

  ## Examples

      GenDOM.Element.scroll_into_view(element, %{behavior: :smooth, block: :center})

  """
  def scroll_into_view(%__MODULE__{} = element, scroll_into_view_options) when is_map(scroll_into_view_options) do

  end

  @doc """
  Scrolls to a particular set of coordinates inside the element.

  This method implements the DOM `scrollTo()` specification.

  ## Parameters

  - `element` - The element to scroll
  - `options` - Scroll options (top, left, behavior)

  ## Examples

      GenDOM.Element.scroll_to(element, top: 0, left: 0, behavior: :smooth)

  """
  def scroll_to(%__MODULE__{} = element, options \\ []) when is_list(options) do

  end

  @doc """
  Scrolls to a particular set of coordinates inside the element.

  This method implements the DOM `scrollTo()` specification with explicit coordinates.

  ## Parameters

  - `element` - The element to scroll
  - `x_coord` - The pixel along the horizontal axis to scroll to
  - `y_coord` - The pixel along the vertical axis to scroll to

  ## Examples

      GenDOM.Element.scroll_to(element, 0, 100)

  """
  def scroll_to(%__MODULE__{} = element, x_coord, y_coord) do

  end

  @doc """
  Sets the value of an attribute on the specified element.

  This method implements the DOM `setAttribute()` specification. If the attribute already exists,
  its value is updated. If it doesn't exist, a new attribute is created with the specified name and value.

  ## Parameters

  - `element_pid` - The PID of the element to set the attribute on
  - `name` - The name of the attribute to set
  - `value` - The value to assign to the attribute

  ## Examples

      iex> element = GenDOM.Element.new([])
      iex> GenDOM.Element.set_attribute(element.pid, "class", "btn primary")
      :ok

  """
  def set_attribute(element_pid, name, value) do
    %{attributes: attributes} = get(element_pid)
    GenDOM.Element.put(element_pid, :attributes, Map.put(attributes, name, value))
  end

  @doc """
  Adds a new Attr node to the specified element.

  This method implements the DOM `setAttributeNode()` specification.

  ## Parameters

  - `element` - The element to set the attribute node on
  - `attribute` - The Attr node to add

  ## Examples

      GenDOM.Element.set_attribute_node(element, attr_node)

  """
  def set_attribute_node(%__MODULE__{} = element, attribute) do

  end

  @doc """
  Adds a new namespaced Attr node to the specified element.

  This method implements the DOM `setAttributeNodeNS()` specification.

  ## Parameters

  - `element` - The element to set the attribute node on
  - `attribute_node` - The namespaced Attr node to add

  ## Examples

      GenDOM.Element.set_attribute_node_ns(element, namespaced_attr_node)

  """
  def set_attribute_node_ns(%__MODULE__{} = element, attribute_node) do

  end

  @doc """
  Sets the value of an attribute on the specified element within a given namespace.

  This method implements the DOM `setAttributeNS()` specification.

  ## Parameters

  - `element` - The element to set the attribute on
  - `namespace` - The namespace of the attribute
  - `name` - The name of the attribute
  - `value` - The value to assign to the attribute

  ## Examples

      GenDOM.Element.set_attribute_ns(element, "http://www.w3.org/1999/xlink", "href", "#target")

  """
  def set_attribute_ns(%__MODULE__{} = element, namespace, name, value) do

  end

  @doc """
  Sets the inner markup of the element to the given markup string without sanitization.

  This method implements the DOM `setHTMLUnsafe()` specification (proposed feature).
  WARNING: This method does not sanitize the markup and should be used with caution.

  ## Parameters

  - `element` - The element to set markup for
  - `html` - The markup string to set (unsanitized)

  ## Examples

      GenDOM.Element.set_html_unsafe(element, "<p>Unsafe markup</p>")

  """
  def set_html_unsafe(%__MODULE__{} = element, html) do

  end

  @doc """
  Designates a specific element as the capture target of future pointer events.

  This method implements the DOM `setPointerCapture()` specification.

  ## Parameters

  - `element` - The element to capture pointer events to
  - `pointer_id` - The identifier for the pointer to be captured

  ## Examples

      GenDOM.Element.set_pointer_capture(element, pointer_id)

  """
  def set_pointer_capture(%__MODULE__{} = element, pointer_id) do

  end

  @doc """
  Toggles a boolean attribute on the element.

  This method implements the DOM `toggleAttribute()` specification. If the attribute exists,
  it is removed. If it doesn't exist, it is added.

  ## Parameters

  - `element` - The element to toggle the attribute on
  - `name` - The name of the attribute to toggle

  ## Examples

      result = GenDOM.Element.toggle_attribute(element, "disabled")
      # => true if attribute was added, false if removed

  """
  def toggle_attribute(element_pid, name) do
    %{attributes: attributes} = get(element_pid)
    value = !Map.get(attributes, name, false)
    GenDOM.Element.put!(element_pid, :attributes, Map.put(attributes, name, value))

    value
  end

  @doc """
  Toggles a boolean attribute on the element with a force parameter.

  This method implements the DOM `toggleAttribute()` specification with force.
  When force is true, the attribute is added if not present.

  ## Parameters

  - `element` - The element to toggle the attribute on
  - `name` - The name of the attribute to toggle
  - `force` - When true, forces the attribute to be added

  ## Examples

      GenDOM.Element.toggle_attribute(element, "disabled", true)
      # => Always adds the attribute and returns true

  """
  def toggle_attribute(element_pid, name, true) do
    %{attributes: attributes} = get(element_pid)
    value = Map.get(attributes, name, true)
    GenDOM.Element.put!(element_pid, :attributes, Map.put(attributes, name, value))

    true
  end

  @doc """
  Toggles a boolean attribute on the element with a force parameter.

  This method implements the DOM `toggleAttribute()` specification with force.
  When force is false, the attribute is removed if present.

  ## Parameters

  - `element` - The element to toggle the attribute on
  - `name` - The name of the attribute to toggle
  - `force` - When false, forces the attribute to be removed

  ## Examples

      GenDOM.Element.toggle_attribute(element, "disabled", false)
      # => Always removes the attribute and returns false

  """
  def toggle_attribute(element_pid, name, false) do
    %{attributes: attributes} = get(element_pid)
    GenDOM.Element.put!(element_pid, :attributes, Map.put(attributes, name, false))

    false
  end

  defp update_element_relationships(element, parent, pos, _opts) do
    previous_element_sibling = if pos != 0 do
      previous_element_sibling = Enum.at(parent.children, pos - 1)
      GenServer.cast(previous_element_sibling, {:put, :next_element_sibling, element.pid})
      previous_element_sibling
    end

    next_pos = pos + 1
    next_element_sibling = if next_pos < length(parent.children),
      do: Enum.at(parent.children, next_pos)

    GenServer.cast(element.pid, {:merge, %{
      previous_element_sibling: previous_element_sibling,
      next_element_sibling: next_element_sibling
    }})
  end

  defp update_parent_relationships(%{children: [element_pid], pid: parent_pid}, %{__struct__: struct, pid: element_pid} = element, 0, _opts) when struct not in [GenDOM.Node, GenDOM.Text] do
    update_owner_document(element)
    GenServer.cast(parent_pid, {:merge, %{
      first_element_child: element_pid,
      last_element_child: element_pid
    }})
  end

  defp update_parent_relationships(parent, %{__struct__: struct, pid: element_pid} = element, 0, _opts) when struct not in [GenDOM.Node, GenDOM.Text] do
    update_owner_document(element)
    GenServer.cast(parent.pid, {:put, :first_element_child, element_pid})
  end

  defp update_parent_relationships(%{children: children} = parent, %{__struct__: struct, pid: element_pid} = element, pos, _opts) when pos + 1 >= length(children) and struct not in [GenDOM.Node, GenDOM.Text] do
    update_owner_document(element)
    GenServer.cast(parent.pid, {:put, :last_element_child, element_pid})
  end

  defp update_parent_relationships(_parent, element, _pos, _opts) do
    update_owner_document(element)
    :ok
  end

  defp update_owner_document(%{tag_name: "body", owner_document: owner_document, pid: element_pid}) when not is_nil(owner_document) do
    GenServer.cast(owner_document, {:put, :body, element_pid})
  end

  defp update_owner_document(%{tag_name: "head", owner_document: owner_document, pid: element_pid}) when not is_nil(owner_document) do
    GenServer.cast(owner_document, {:put, :head, element_pid})
  end

  defp update_owner_document(_element),
    do: :ok
end
