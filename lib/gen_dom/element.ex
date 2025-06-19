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
    class_name: "",
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

  defp extract_fields_from_attributes(attributes) do
    Enum.reduce(attributes, %{}, &extract_fields_from_attribute(&1, &2))
  end

  defp extract_fields_from_attribute({"id", id}, fields) do
    Map.put(fields, :id, id)
  end

  defp extract_fields_from_attribute({"class", class_name}, fields) do
    Map.merge(fields, %{
      class_name: class_name,
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

  def match(element, matcher, opts \\ [])

  def match(%__MODULE__{} = element, {:tag_name, "*", _rule_opts}, _opts) do
    element
  end

  def match(%__MODULE__{tag_name: tag_name} = element, {:tag_name, tag_name, _rule_opts}, _opts) do
    element
  end

  def match(%__MODULE__{id: id} = element, {:id, id}, _opts) do
    element
  end

  def match(%__MODULE__{attributes: attributes} = element, {:attribute, {compare_type, name, compare_value, attr_opts}}, _opts) do
    name = apply_namespace(name, attr_opts[:namespace])

    with {:ok, actual_value} <- Map.fetch(attributes, name),
      {actual_value, compare_value} <- apply_case_sensitivity(actual_value, compare_value, attr_opts[:i]),
      true <- attribute_compare(compare_type, actual_value, compare_value, attr_opts) do
        element
    else
      _ -> nil
    end
  end
  
  def match(%__MODULE__{} = element, {:class, name}, _opts) when is_binary(name) do
    if name in element.class_list,
      do: element,
      else: nil
  end

  def match(%__MODULE__{} = element, {:class, names}, _opts) when is_list(names) do
    case (for name <- names, name in element.class_list, do: name) do
      [] -> nil
      _names -> element
    end
  end

  def match(%__MODULE__{} = element, {:pseudo_class, {type, params}}, opts) do
    Pseudo.match(element, type, params, opts)
  end

  def match(%__MODULE__{} = element, {:selectors, selectors}, opts) do
    all_descendants = :pg.get_members(element.pid)

    tasks = Enum.reduce(all_descendants, [], fn(pid, tasks) ->
      Enum.reduce(selectors, tasks, fn(selector, tasks) ->
        task = Task.async(fn ->
          element = GenServer.call(pid, :get)
          __MODULE__.match(element, selector, opts)
        end)

        [task | tasks]
      end)
    end)

    case opts[:await].(tasks) do
      child_elements when is_list(child_elements) ->
        Enum.reduce(selectors, child_elements, fn(selector, child_elements) ->
          case match(element, selector, opts) do
            nil -> child_elements
            child_element -> [child_element | child_elements]
          end
        end)

      nil ->
        Enum.reduce_while(selectors, nil, fn
          selector, nil ->
            case match(element, selector, opts) do
              nil -> {:cont, nil}
              element -> {:halt, element}
            end
        end)

      child_element -> child_element
    end
  end

  def match(%__MODULE__{} = element, {:rules, [rule]}, opts) do
    match(element, rule, opts)
  end

  def match(%__MODULE__{} = element, {:rules, [rule | [{:rule, _next_rules, next_rule_opts} | _] = rules]}, opts) do
    rules = if match(element, rule, opts) do
      rules
    else
      [rule | rules]
    end

    {pids, opts} = apply_combinator(element, next_rule_opts[:combinator], opts)

    tasks = Enum.map(pids, fn(pid) ->
      Task.async(fn ->
        case GenServer.call(pid, :get) do
          %__MODULE__{} = element ->
            __MODULE__.match(element, {:rules, rules}, opts)
          _node -> nil
        end
      end)
    end)

    opts[:await].(tasks)
  end

  def match(%__MODULE__{} = element, {:rule, segments, _rule_opts}, opts) do
    Enum.reduce_while(segments, element, fn(segment, element) ->
      case match(element, segment, opts) do
        nil -> {:halt, nil}
        _element -> {:cont, element}
      end
    end)
  end

  def match(_element, _matcher, _opts) do
    nil
  end

  defp apply_combinator(%__MODULE__{} = element, nil, opts) do
    if Keyword.get(opts, :recursive, true) do
      {:pg.get_members(element.pid), opts}
    else
      {[], opts}
    end
  end

  defp apply_combinator(%__MODULE__{} = element, ">", opts) do
    {element.child_nodes, Keyword.put(opts, :recursive, false)}  
  end

  defp apply_combinator(%__MODULE__{} = element, "+", opts) do
    parent = GenServer.call(element.parent_element, :get)
    element_idx = Enum.find_index(parent.child_nodes, &(&1 == element.pid))
    pids = case Enum.at(parent.child_nodes, element_idx + 1) do
      nil -> []
      sibling_pid -> [sibling_pid]
    end

    {pids, Keyword.put(opts, :recursive, false)}
  end

  defp apply_combinator(%__MODULE__{} = element, "~", opts) do
    parent = GenServer.call(element.parent_element, :get)
    element_pid = element.pid
    {_bool, pids} = Enum.reduce(parent.child_nodes, {false, []}, fn
      ^element_pid, {false, []} -> {true, []}
      child_pid, {true, child_pids} -> {true, [child_pid | child_pids]}
      _child_pid, {false, _child_pids} -> {false, []}
    end)

    {pids, Keyword.put(opts, :recursive, false)}
  end

  defp attribute_compare(:exists, _actual_value, _compare_value, _opts) do
    true
  end

  defp attribute_compare(:equal, actual_value, compare_value, _opts) do
    actual_value == compare_value
  end

  defp attribute_compare(:prefix, actual_value, compare_value, _opts) do
    String.starts_with?(actual_value, compare_value)
  end

  defp attribute_compare(:suffix, actual_value, compare_value, _opts) do
    String.ends_with?(actual_value, compare_value)
  end

  defp attribute_compare(:dash_match, actual_value, compare_value, _opts) do
    split_actual_value = String.split(actual_value, "-")

    compare_value in split_actual_value
  end

  defp attribute_compare(:substring, actual_value, compare_value, _opts) do
    String.contains?(actual_value, compare_value)
  end

  defp attribute_compare(:includes, actual_value, compare_value, _opts) do
    split_compare_value = String.split(compare_value)

    Enum.any?(split_compare_value, fn(compare_value) ->
      String.contains?(actual_value, compare_value)
    end)
  end

  defp apply_case_sensitivity(string_a, string_b, nil) do
    {string_a, string_b}
  end

  defp apply_case_sensitivity(string_a, string_b, _i) do
    {String.downcase(string_a), String.downcase(string_b)}
  end

  defp apply_namespace(name, nil) do
    name
  end

  defp apply_namespace(name, namespace) do
    "#{namespace}:#{name}"
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

  def get_attribute(%__MODULE__{} = element, attribute_name) do

  end

  def get_attribute_names(%__MODULE__{} = element) do

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

  def has_attribute?(%__MODULE__{} = element, name) do

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

  def set_attribute(%__MODULE__{} = element, name, value) do

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

  def toggle_attribute(%__MODULE__{} = element) do

  end

  def toggle_attribute(%__MODULE__{} = element, force?) when is_boolean(force?) do

  end
end
