defmodule GenDOM.Element do
  @derive {Inspect, only: [:pid, :tag_name, :id, :class_list, :attributes]}

  alias GenDOM.{
    Match.Pseudo
  }

  use GenDOM.Node, [
    active_element: nil,
    adopted_style_sheets: nil,
    node_type: 1,

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

      @fields unquote(Macro.escape(fields))
      @fields unquote(Macro.escape(@fields))

      use GenDOM.Node
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

  def init(opts) do
    {:ok, element} = super(opts)

    fields = extract_fields_from_attributes(Keyword.get(opts, :attributes, %{}))

    {:ok, struct(element, fields)}
  end

  def clone_node(node, deep? \\ false) do
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
      Enum.reduce(node.child_nodes, new_node, fn(child_node_pid, new_node) ->
        child_node = GenServer.call(child_node_pid, :get)
        append_child(new_node, clone_node(child_node, deep?))
      end)
    else
      new_node
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


  def allowed_fields,
    do: super() ++ [:class_list, :id, :attributes, :tag_name]

  # Elixir has `after` as a reserved keyword so this must be called `do_after`
  def do_after(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  def animate(%__MODULE__{} = element, keyframes, options \\ []) do

  end

  def append(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  def attach_shadow(%__MODULE__{} = element, options \\ []) do

  end

  def before(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  def check_visibility(%__MODULE__{} = element, options \\ []) do

  end

  def closest(%__MODULE__{} = element, selectors) when is_binary(selectors) do

  end

  def computed_style_map(%__MODULE__{} = element) do

  end

  def get_animations(%__MODULE__{} = element, options \\ []) do

  end

  def get_attribute(%__MODULE__{attributes: attributes} = _element, attribute_name) do
    Map.get(attributes, attribute_name)
  end

  def get_attribute_names(%__MODULE__{attributes: attributes, class_list: class_list, id: id}) do
    Map.keys(attributes)
  end

  def get_attribute_node(%__MODULE__{} = element, attribute_name) do

  end

  def get_attribute_node_ns(%__MODULE__{} = element, namespace, node_name) do

  end

  def get_attribute_ns(%__MODULE__{} = element, namespace, name) do

  end

  def get_bounding_client_rect(%__MODULE__{} = element) do

  end

  def get_client_rects(%__MODULE__{} = element) do

  end

  def get_elements_by_class_name(%__MODULE__{} = element, names) do
    query = Stream.map(names, &(".#{&1}")) |> Enum.join(",")

    GenServer.call(element.pid, {:query_selector_all, query})
  end

  def get_elements_by_tag_name(%__MODULE__{} = element, tag_name) do
    GenServer.call(element.pid, {:query_selector_all, tag_name})
  end

  def get_elements_by_tag_name_ns(%__MODULE__{} = element, namespace, local_name) do
    query = "#{namespace}|#{local_name}"
    GenServer.call(element.pid, {:query_selector_all, query})
  end

  def get_html(%__MODULE__{} = element, options \\ []) do

  end

  def has_attribute?(%__MODULE__{attributes: attributes} = element, name) do
    Map.has_key?(attributes, name)
  end

  def has_attribute_ns?(%__MODULE__{} = element, namespace, local_name) do

  end

  def has_attributes?(%__MODULE__{} = element) do

  end

  def has_pointer_capture?(%__MODULE__{} = element, pointer_id) do

  end

  def insert_adjacent_element(%__MODULE__{} = element, position, %__MODULE__{} = other_element) do

  end

  def insert_adjacent_html(%__MODULE__{} = element, position, text) when is_binary(text) do

  end

  def insert_adjacent_text(%__MODULE__{} = element, where, data) when is_binary(data) do

  end

  def import_node(%__MODULE__{} = element, external_node, deep?) do

  end

  def prepend(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  def query_selector(%__MODULE__{} = element, selectors) when is_binary(selectors) do
  end

  def query_selector_all(%__MODULE__{} = element, selectors) when is_binary(selectors) do
    selectors = Selector.parse(selectors)
    GenServer.call(element.pid, {:query_selector_all, selectors})
  end

  def release_pointer_capture(%__MODULE__{} = element, pointer_id) do

  end

  def remove(%__MODULE__{} = element) do

  end

  def remove_attribute(%__MODULE__{} = element, attribute_name) do

  end

  def remove_attribute_node(%__MODULE__{} = element, attribute_node) do

  end

  def remove_attribute_ns(%__MODULE__{} = element, namespace, attribute_node) do

  end

  def replace_children(%__MODULE__{} = element, children) when is_list(children) do

  end

  def replace_with(%__MODULE__{} = element, nodes) when is_list(nodes) do

  end

  def request_fullscreen(%__MODULE__{} = element, options \\ []) do

  end

  def request_pointer_lock(%__MODULE__{} = element, options \\ []) do

  end

  def scroll(%__MODULE__{} = element, options \\ []) do

  end

  def scroll(%__MODULE__{} = element, x_coord, y_coord) do

  end

  def scroll_by(%__MODULE__{} = element, options \\ []) do

  end

  def scroll_into_view(%__MODULE__{} = element, align_to_top) when is_boolean(align_to_top) do

  end

  def scroll_into_view(%__MODULE__{} = element, scroll_into_view_options) when is_map(scroll_into_view_options) do

  end

  def scroll_to(%__MODULE__{} = element, options \\ []) when is_list(options) do

  end

  def scroll_to(%__MODULE__{} = element, x_coord, y_coord) do

  end

  def set_attribute(%__MODULE__{attributes: attributes} = element, name, value) do
    Element.put(element, :attributes, Map.put(attributes, name, value))
  end

  def set_attribute_node(%__MODULE__{} = element, attribute) do

  end

  def set_attribute_node_ns(%__MODULE__{} = element, attribute_node) do

  end

  def set_attribute_ns(%__MODULE__{} = element, namespace, name, value) do

  end

  def set_html_unsafe(%__MODULE__{} = element, html) do

  end

  def set_pointer_capture(%__MODULE__{} = element, pointer_id) do

  end

  def toggle_attribute(%__MODULE__{attributes: attributes} = element, name) do
    value = !Map.get(attributes, name, false)
    Element.put!(element, :attributes, Map.put(attributes, name, value))

    value
  end

  def toggle_attribute(%__MODULE__{attributes: attributes} = element, name, true) do
    value = Map.get(attributes, name, true)
    Element.put!(element, :attributes, Map.put(attributes, name, value))

    true
  end

  def toggle_attribute(%__MODULE__{attributes: attributes} = element, name, false) do
    Element.put!(element, :attributes, Map.put(attributes, name, false))

    false
  end
end
