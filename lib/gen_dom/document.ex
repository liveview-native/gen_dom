defmodule GenDOM.Document do
  alias GenDOM.{
    Element,
    Matcher
  }

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

  defguardp is_timeout(timeout)
    when timeout == :infinity or (is_integer(timeout) and timeout >= 0)

  def encode(document) do
    Map.merge(super(document), %{
      style_sheets: document.style_sheets,
      title: document.title,
      url: document.url,
      body: document.body,
      head: document.head,
    })
  end

  def allowed_fields,
    do: super() ++ [:title, :body, :head]

  @impl true

  def handle_info({:DOWN, ref, :process, pid, :normal}, document) when is_reference(ref) and is_pid(pid) do
    {:noreply, document}
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

  def await_one(tasks, timeout \\ 5_000) when is_list(tasks) do
    awaiting =
      Map.new(tasks, fn %Task{ref: ref, owner: owner} = task ->
        if owner != self() do
          raise ArgumentError, invalid_owner_error(task)
        end

        {ref, true}
      end)

    timeout_ref = make_ref()

    timer_ref =
      if timeout != :infinity do
        Process.send_after(self(), timeout_ref, timeout)
      end

    try do
      await_one(tasks, timeout, awaiting, timeout_ref)
    after
      timer_ref && Process.cancel_timer(timer_ref)
      receive do: (^timeout_ref -> :ok), after: (0 -> :ok)
    end
  end

  def await_one(_tasks, _timeout, awaiting, _timeout_ref) when map_size(awaiting) == 0 do
    nil
  end

  def await_one(tasks, timeout, awaiting, timeout_ref) do
    receive do
      ^timeout_ref ->
        demonitor_pending_tasks(awaiting)
        exit({:timeout, {__MODULE__, :await_one, [tasks, timeout]}})

      {:DOWN, ref, _, proc, reason} when is_map_key(awaiting, ref) ->
        demonitor_pending_tasks(awaiting)
        exit({reason(reason, proc), {__MODULE__, :await_many, [tasks, timeout]}})

      {ref, nil} when is_map_key(awaiting, ref) ->
        demonitor(ref)
        await_one(tasks, timeout, Map.delete(awaiting, ref), timeout_ref)

      {ref, reply} when is_map_key(awaiting, ref) ->
        awaiting = Map.delete(awaiting, ref)
        demonitor_pending_tasks(awaiting)
        # shutdown_pending_tasks(awaiting)

        reply
    end
  end

  def await_many(tasks, timeout \\ 60_000) when is_timeout(timeout) do
    awaiting =
      Map.new(tasks, fn %Task{ref: ref, owner: owner} = task ->
        if owner != self() do
          raise ArgumentError, invalid_owner_error(task)
        end

        {ref, true}
      end)

    timeout_ref = make_ref()

    timer_ref =
      if timeout != :infinity do
        Process.send_after(self(), timeout_ref, timeout)
      end

    try do
      await_many(tasks, timeout, awaiting, %{}, timeout_ref)
    after
      timer_ref && Process.cancel_timer(timer_ref)
      receive do: (^timeout_ref -> :ok), after: (0 -> :ok)
    end
  end

  defp await_many(tasks, _timeout, awaiting, replies, _timeout_ref)
       when map_size(awaiting) == 0 do
    for %{ref: ref} <- tasks, do: Map.fetch!(replies, ref)
  end

  defp await_many(tasks, timeout, awaiting, replies, timeout_ref) do
    receive do
      ^timeout_ref ->
        demonitor_pending_tasks(awaiting)
        exit({:timeout, {__MODULE__, :await_many, [tasks, timeout]}})

      {:DOWN, ref, _, proc, reason} when is_map_key(awaiting, ref) ->
        demonitor_pending_tasks(awaiting)
        exit({reason(reason, proc), {__MODULE__, :await_many, [tasks, timeout]}})

      {ref, nil} when is_map_key(awaiting, ref) ->
        demonitor(ref)

        await_many(
          Enum.reject(tasks, &(&1.ref == ref)),
          timeout,
          Map.delete(awaiting, ref),
          replies,
          timeout_ref
        )

      {ref, reply} when is_map_key(awaiting, ref) ->
        demonitor(ref)

        await_many(
          tasks,
          timeout,
          Map.delete(awaiting, ref),
          Map.put(replies, ref, reply),
          timeout_ref
        )
    end
  end

  defp demonitor_pending_tasks(awaiting) do
    Enum.each(awaiting, fn {ref, _} ->
      demonitor(ref)
    end)
  end

  defp reason(:noconnection, proc), do: {:nodedown, monitor_node(proc)}
  defp reason(reason, _), do: reason

  defp monitor_node(pid) when is_pid(pid), do: node(pid)
  defp monitor_node({_, node}), do: node

  defp demonitor(ref) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    :ok
  end

  defp invalid_owner_error(task) do
    "task #{inspect(task)} must be queried from the owner but was queried from #{inspect(self())}"
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
    all_descendants = :pg.get_members(document.pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, {:id, id})
      end)
    end)

    await_one(tasks)
  end

  def get_elements_by_class_name(%__MODULE__{} = document, names) do
    names = String.split(names)
    all_descendants = :pg.get_members(document.pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, {:class, names})
      end)
    end)

    await_many(tasks)
  end

  def get_elements_by_name(%__MODULE__{} = document, name) do
    query_selector_all(document, ~s([name="#{name}"]))
  end

  def get_elements_by_tag_name(%__MODULE__{} = document, tag_name) do
    all_descendants = :pg.get_members(document.pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, {:tag_name, tag_name})
      end)
    end)

    await_many(tasks)
  end

  def get_elements_by_tag_name_ns(%__MODULE__{} = document, namespace, local_name) do
    query_selector_all(document, "#{namespace}|#{local_name}")
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

  def query_selector(%__MODULE__{} = document, selectors) when is_binary(selectors) do
    selectors = Selector.parse(selectors)
    all_descendants = :pg.get_members(document.pid)

    tasks = Enum.map(all_descendants, fn(pid) ->
      Task.async(fn ->
        element = GenServer.call(pid, :get)
        Matcher.match(element, selectors, await: &await_one/1)
      end)
    end)

    await_one(tasks)
  end

  def query_selector_all(%__MODULE__{} = document, selectors) when is_binary(selectors) do
    selectors = Selector.parse(selectors)
    # all_descendants = :pg.get_members(document.pid)

    tasks = Enum.map(document.child_nodes, fn(pid) ->
      Task.async(fn ->
        case GenServer.call(pid, :get) do
          %Element{} = element ->
            Matcher.match(element, selectors, await: &await_many/1)
          _node ->
            nil
        end
      end)
    end)

    await_many(tasks)
    |> List.flatten()
    |> Enum.uniq()
  end

  def request_storage_access(%__MODULE__{} = document, types \\ %{all: true}) do

  end

  def start_view_transition(%__MODULE__{} = document, update_callback) do

  end

  def writeln(%__MODULE__{} = document, line) when is_binary(line) do

  end

end
