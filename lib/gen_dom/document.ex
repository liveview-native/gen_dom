defmodule GenDOM.Document do
  use GenDOM.Node, [
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

  @impl true
  def handle_call({:query_selector, selector}, _from, document) do
    if matches_selector?(document, selector) do
      {:reply, {:ok, document}, document}
    else
      case query_children_for_first_match(document, selector) do
        {:ok, result} -> {:reply, {:ok, result}, document}
        error -> {:reply, error, document}
      end
    end
  end

  @impl true
  def handle_call({:query_selector_all, selector}, _from, document) do
    matches = if matches_selector?(document, selector), do: [document], else: []

    case query_children_for_all_matches(document, selector) do
      {:ok, child_matches} -> {:reply, {:ok, matches ++ child_matches}, document}
      _ -> {:reply, {:ok, matches}, document}
    end
  end

  defp query_children_for_first_match(node, selector) do
    child_nodes = node.child_nodes || []

    if child_nodes == [] do
      {:error, :not_found}
    else
      Enum.reduce_while(child_nodes, {:error, :not_found}, fn child_name, acc ->
        child = GenServer.call(child_name, :get)

        if matches_selector?(child, selector) do
          {:halt, {:ok, child}}
        else
          case query_children_for_first_match(child, selector) do
            {:ok, matching_node} -> {:halt, {:ok, matching_node}}
            _ -> {:cont, acc}
          end
        end
      end)
    end
  end

  defp matches_selector?(child, selector) do
    false
  end

  defp query_children_for_all_matches(node, selector) do
    child_nodes = node.child_nodes || []

    if child_nodes == [] do
      {:ok, []}
    else
      child_matches = Enum.flat_map(child_nodes, fn child_name ->
        child = GenServer.call(child_name, :get)

        direct_matches = if matches_selector?(child, selector), do: [child], else: []

        child_children_matches = case query_children_for_all_matches(child, selector) do
          {:ok, matching_nodes} when is_list(matching_nodes) -> matching_nodes
          _ -> []
        end

        direct_matches ++ child_children_matches
      end)

      {:ok, child_matches}
    end
  end


  def adopt_node(%__MODULE__{} = _document, _node) do

  end

  def append(%__MODULE__{} = document, nodes) when is_list(nodes) do

  end

  def caret_position_from_point(%__MODULE__{} = docuemnt, x, y, options \\ []) do

  end

  def close(%__MODULE__{} = document) do

  end

  def create_attribute(%__MODULE__{} = document, name) do

  end

  def create_attribute_ns(%__MODULE__{} = document, namespace_uri, qualified_name) do

  end

  def create_CDATA_section(%__MODULE__{} = document, data) do

  end

  def create_comment(%__MODULE__{} = document, data) do

  end

  def create_document_fragment(%__MODULE__{} = document) do

  end

  def create_element(%__MODULE__{} = document, local_name, options \\ []) do

  end

  def create_element_ns(%__MODULE__{} = document, namespace_uri, qualified_name, options \\ []) do

  end

  def create_expression(%__MODULE__{} = document, xpath_text, namespace_url_mapper) do

  end

  def create_node_iterator(%__MODULE__{} = document, root, what_to_show, filter) do

  end

  def create_processing_instruction(%__MODULE__{} = document, target, data) do

  end

  def create_range(%__MODULE__{} = document) do

  end

  def create_text_node(%__MODULE__{} = document, data) do

  end

  def create_tree_walker(%__MODULE__{} = document, root, what_to_show, filter) do

  end

  def element_from_point(%__MODULE__{} = document, x, y) do

  end

  def elements_from_point(%__MODULE__{} = document, x, y) do

  end

  def evaluate(%__MODULE__{} = document, xpath_expression, context_node, namespace_resolver, result_type, result) do

  end

  def exit_fullscreen(%__MODULE__{} = document) do

  end

  def exit_picture_in_picture(%__MODULE__{} = document) do

  end

  def exit_pointer_lock(%__MODULE__{} = document) do

  end

  def get_animations(%__MODULE__{} = document) do

  end

  def get_element_by_id(%__MODULE__{} = document, id) do

  end

  def get_elements_by_class_name(%__MODULE__{} = document, names) do

  end

  def get_elements_by_name(%__MODULE__{} = document, name) do

  end

  def get_elements_by_tag_name(%__MODULE__{} = document, name) do

  end

  def get_elements_by_tag_name_ns(%__MODULE__{} = document, namespace, name) do

  end

  def get_selection(%__MODULE__{} = document) do

  end

  def has_focus?(%__MODULE__{} = document) do

  end

  def has_storage_access?(%__MODULE__{} = document) do

  end

  def has_unpartitioned_cookie_access?(%__MODULE__{} = document) do

  end

  def import_node(%__MODULE__{} = document, external_node, deep?) do

  end

  def open(%__MODULE__{} = document) do

  end

  def prepend(%__MODULE__{} = document, nodes) when is_list(nodes) do

  end



  def replace_children(%__MODULE__{} = document, children) when is_list(children) do

  end

  def query_selector(%__MODULE__{} = document, selector_string) when is_binary(selector_string) do
    GenServer.call(document.pid, {:query_selector, selector_string})
  end

  def query_selector_all(%__MODULE__{} = document, selector_string) when is_binary(selector_string) do
    GenServer.call(document.pid, {:query_selector_all, selector_string})
  end

  def request_storage_access(%__MODULE__{} = document, types \\ %{all: true}) do

  end

  def start_view_transition(%__MODULE__{} = document, update_callback) do

  end

  def writeln(%__MODULE__{} = document, line) when is_binary(line) do

  end

end
