defmodule GenDOM.Node do
  use GenServer

  @properties [
    assigns: %{},
    pid: nil,
    receiver: nil,

    base_uri: nil,
    child_nodes: [],
    first_child: nil,
    is_connected: false,
    last_child: nil,
    next_sibling: nil,
    node_name: nil,
    node_type: 0,
    node_value: nil,
    owner_document: nil,
    parent_element: nil,
    parent_node: nil,
    previous_sibling: nil,
    text_content: nil
  ]

  defmacro __using__(fields \\ []) do
    quote do
      use GenServer

      defstruct Keyword.merge(unquote(Macro.escape(@properties)), unquote(Macro.escape(fields)))

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts)
      end

      @impl true
      def init(opts) do
        pid = self()
        :pg.start_link()
        :pg.monitor(pid)

        mod = __MODULE__

        {:ok, struct(%__MODULE__{}, Keyword.put(opts, :pid, pid))}
      end

      defoverridable init: 1

      defdelegate encode(node), to: GenDOM.Node
      defoverridable encode: 1

      defdelegate allowed_fields(), to: GenDOM.Node
      defoverridable allowed_fields: 0

      def new(opts \\ []) when is_list(opts) do
        case start_link(opts) do
          {:ok, pid} -> GenServer.call(pid, :get)
          _other -> {:error, "could not start"}
        end
      end
      defoverridable new: 1

      defdelegate append_child(node, child), to: GenDOM.Node
      defdelegate append_child(node, child, opts), to: GenDOM.Node
      defdelegate append_child!(node, child), to: GenDOM.Node
      defdelegate append_child!(node, child, opts), to: GenDOM.Node
      defdelegate compare_document_position(node, other_node), to: GenDOM.Node
      defdelegate contains?(node, other_node), to: GenDOM.Node
      defdelegate has_child_nodes?(node), to: GenDOM.Node
      defdelegate insert_before(node, new_node, reference_node), to: GenDOM.Node
      defdelegate insert_before(node, new_node, reference_node, opts), to: GenDOM.Node
      defdelegate insert_before!(node, new_node, reference_node), to: GenDOM.Node
      defdelegate insert_before!(node, new_node, reference_node, opts), to: GenDOM.Node
      defdelegate is_default_namespace?(node, uri), to: GenDOM.Node
      defdelegate is_equal_node?(node, other_node), to: GenDOM.Node
      defdelegate is_same_node?(node, other_node), to: GenDOM.Node
      defdelegate lookup_namespace_uri(node, prefix), to: GenDOM.Node
      defdelegate lookup_prefix(node, namespace), to: GenDOM.Node
      defdelegate normalize(node), to: GenDOM.Node
      defdelegate remove_child(node, child), to: GenDOM.Node
      defdelegate remove_child(node, child, opts), to: GenDOM.Node
      defdelegate remove_child!(node, child), to: GenDOM.Node
      defdelegate remove_child!(node, child, opts), to: GenDOM.Node
      defdelegate replace_child(node, new_child, old_child), to: GenDOM.Node
      defdelegate replace_child(node, new_child, old_child, opts), to: GenDOM.Node
      defdelegate replace_child!(node, new_child, old_child), to: GenDOM.Node
      defdelegate replace_child!(node, new_child, old_child, opts), to: GenDOM.Node

      defdelegate get(node), to: GenDOM.Node
      defdelegate assign(node, assigns), to: GenDOM.Node
      defdelegate assign!(node, assigns), to: GenDOM.Node
      defdelegate put(node, key, value), to: GenDOM.Node
      defdelegate put!(node, key, value), to: GenDOM.Node
      defdelegate merge(node, fields), to: GenDOM.Node
      defdelegate merge!(node, fields), to: GenDOM.Node

      @impl true
      def handle_call(:get, from, node), do: GenDOM.Node.handle_call(:get, from, node)
      def handle_call({:assign, assigns}, from, node), do: GenDOM.Node.handle_call({:assign, assigns}, from, node)
      def handle_call({:merge, fields}, from, node), do: GenDOM.Node.handle_call({:merge, fields}, from, node)
      def handle_call({:put, field, value}, from, node), do: GenDOM.Node.handle_call({:put, field, value}, from, node)

      def handle_call({:append_child, child, opts}, from, node), do: GenDOM.Node.handle_call({:append_child, child, opts}, from, node)
      def handle_call({:insert_before, new_node, reference_node, opts}, from, node), do: GenDOM.Node.handle_call({:insert_before, new_node, reference_node, opts}, from, node)
      def handle_call({:remove_child, child, opts}, from, node), do: GenDOM.Node.handle_call({:remove_child, child, opts}, from, node)
      def handle_call({:replace_child, new_child, old_child, opts}, from, node), do: GenDOM.Node.handle_call({:replace_child, new_child, old_child, opts}, from, node)

      def handle_call({:track, child_pid_or_pids}, from, node), do: GenDOM.Node.handle_call({:track, child_pid_or_pids}, from, node)
      def handle_call({:untrack, child_pid_or_pids}, from, node), do: GenDOM.Node.handle_call({:untrack, child_pid_or_pids}, from, node)

      @impl true
      def handle_cast({:assign, assigns}, node), do: GenDOM.Node.handle_cast({:assign, assigns}, node)
      def handle_cast({:merge, fields}, node), do: GenDOM.Node.handle_cast({:merge, fields}, node)
      def handle_cast({:put, field, value}, node), do: GenDOM.Node.handle_cast({:put, field, value}, node)

      def handle_cast({:append_child, child, opts}, node), do: GenDOM.Node.handle_cast({:append_child, child, opts}, node)
      def handle_cast({:insert_before, new_node, reference_node, opts}, node), do: GenDOM.Node.handle_cast({:insert_before, new_node, reference_node, opts}, node)
      def handle_cast({:remove_child, child, opts}, node), do: GenDOM.Node.handle_cast({:remove_child, child, opts}, node)
      def handle_cast({:replace_child, new_child, old_child, opts}, node), do: GenDOM.Node.handle_cast({:replace_child, new_child, old_child, opts}, node)

      def handle_cast({:track, child}, node), do: GenDOM.Node.handle_cast({:track, child}, node)
      def handle_cast({:untrack, child}, node), do: GenDOM.Node.handle_cast({:untrack, child}, node)
      def handle_cast({:send_to_receiver, msg}, node), do: GenDOM.Node.handle_cast({:send_to_receiver, msg}, node)

      @impl true
      def handle_info({ref, msg, group, children}, node), do: GenDOM.Node.handle_info({ref, msg, group, children}, node)
    end
  end

  defstruct @properties

  def start_link(opts) do
    name = GenDOM.generate_name(__MODULE__)
    GenServer.start_link(__MODULE__, Keyword.put(opts, :name, name), name: name)
  end

  @doc """
  Creates a new Node and returns the Node struct.

  This is a convenience function that calls start_link and then immediately gets the Node struct.

  ## Examples

      iex> {:ok, node} = GenDOM.Node.new([])
      iex> %GenDOM.Node{} = node
  """
  def new(opts \\ []) when is_list(opts) do
    case start_link(opts) do
      {:ok, pid} -> GenServer.call(pid, :get)
      _other -> {:error, "could not start"}
    end
  end

  @impl true
  def init(opts) do
    pid = self()

    :pg.start_link()
    :pg.monitor(pid)

    {:ok, struct(%__MODULE__{}, Keyword.put(opts, :pid, pid))}
  end

  @impl true
  def handle_call(:get, _from, node),
    do: {:reply, node, node}

  def handle_call({:assign, assigns}, from, node) when is_list(assigns),
    do: handle_call({:assign, Map.new(assigns)}, from, node)

  def handle_call({:assign, assigns}, _from, node) when is_map(assigns) do
    node = struct(node, assigns: Map.merge(node.assigns, assigns))
    {:reply, node, node}
  end

  def handle_call({:merge, fields}, _from, node) do
    node = do_merge(node, fields)
    {:reply, node, node}
  end

  def handle_call({:put, field, value}, _from, node) do
    node = do_put(node, field, value)
    {:reply, node, node}
  end

  def handle_call({:append_child, child_pid, opts}, _from, parent) do
    parent = do_append_child(parent, child_pid, opts)
    {:reply, parent, parent} 
  end

  def handle_call({:insert_before, new_node_pid, reference_node_pid, opts}, _from, parent) do
    parent = do_insert_before(parent, new_node_pid, reference_node_pid, opts)
    {:reply, parent, parent}
  end

  def handle_call({:remove_child, child_pid, opts}, _from, parent) do
    parent = do_remove_child(parent, child_pid, opts)
    {:reply, parent, parent}
  end

  def handle_call({:replace_child, new_child_pid, old_child_pid, opts}, _from, parent) do
    parent = do_replace_child(parent, new_child_pid, old_child_pid, opts)
    {:reply, parent, parent}
  end

  def handle_call({:track, child_pid_or_children_pids}, _from, node) do
    node = do_track(node, child_pid_or_children_pids)
    {:reply, node, node}
  end

  def handle_call({:untrack, child_pid_or_children_pids}, _from, node) do
    node = do_untrack(node, child_pid_or_children_pids)
    {:reply, node, node}
  end

  @impl true
  def handle_cast({:assign, assigns}, node) when is_list(assigns) do
    handle_cast({:assign, Map.new(assigns)}, node)
  end

  def handle_cast({:assign, assigns}, node) when is_map(assigns) do
    node = struct(node, assigns: Map.merge(node.assigns, assigns))
    {:noreply, node}
  end

  def handle_cast({:merge, fields}, node) do
    {:noreply, do_merge(node, fields)}
  end

  def handle_cast({:put, field, value}, node) do
    node = do_put(node, field, value)
    {:noreply, node}
  end

  def handle_cast({:append_child, child, opts}, node) do
    node = do_append_child(node, child, opts)
    {:noreply, node}
  end

  def handle_cast({:insert_before, new_node, reference_node, opts}, node) do
    node = do_insert_before(node, new_node, reference_node, opts)
    {:noreply, node}
  end

  def handle_cast({:remove_child, child, opts}, node) do
    node = do_remove_child(node, child, opts)
    {:norepy, node}
  end

  def handle_cast({:replace_child, new_child, old_child, opts}, node) do
    node = do_replace_child(node, new_child, old_child, opts)
    {:noreply, node}
  end

  def handle_cast({:track, child_pid_or_children_pids}, node) do
    if node.parent_element, do: GenServer.cast(node.parent_element, {:track, child_pid_or_children_pids})
    :pg.join(node.pid, child_pid_or_children_pids)

    {:noreply, node}
  end

  def handle_cast({:untrack, child_pid_or_children_pids}, node) do
    if node.parent_element, do: GenServer.cast(node.parent_element, {:untrack, child_pid_or_children_pids})
    :pg.leave(node.pid, child_pid_or_children_pids)

    {:noreply, node}
  end

  def handle_cast({:send_to_receiver, msg}, node) do
    if receiver = node.receiver,
      do: send(receiver, msg)

    {:noreply, node}
  end

  @impl true
  def handle_info({_ref, :leave, pid, _children}, %{pid: pid} = node) do
    {:noreply, node}
  end

  def handle_info({_ref, _msg, pid, _children}, %{pid: pid} = node) do
    {:noreply, node}
  end

  def get(pid) when is_pid(pid),
    do: GenServer.call(pid, :get)
  def get(%{pid: pid}),
    do: get(pid)

  def assign(node, key, value) when is_atom(key),
    do: assign(node, %{key => value})
  def assign(node, assigns) do
    GenServer.call(node.pid, {:assign, assigns})
  end

  def assign!(node, key, value) when is_atom(key),
    do: assign!(node, %{key => value})
  def assign!(node, assigns) do
    GenServer.cast(node.pid, {:assign, assigns})
  end

  def put(node, field, value) do
    GenServer.call(node.pid, {:put, field, value})
  end

  def put!(node, field, value) do
    GenServer.cast(node.pid, {:put, field, value})
  end

  defp do_put(node, field, value) do
    node = struct(node, %{field => value})

    allowed_fields = apply(node.__struct__, :allowed_fields, [])

    if field in allowed_fields  && node.owner_document do
      GenServer.cast(node.owner_document, {:send_to_receiver, {:put, self(), field, value}})
    end

    node
  end

  def merge(node, fields) do
    GenServer.call(node.pid, {:merge, fields})
  end

  def merge!(node, fields) do
    GenServer.cast(node.pid, {:merge, fields})
  end

  defp do_merge(node, fields) do
    node = struct(node, fields)

    if node.owner_document do
      allowed_fields = apply(node.__struct__, :allowed_fields, [])
      fields = Map.drop(fields, allowed_fields)

      if !Enum.empty?(fields) do
        GenServer.cast(node.owner_document, {:send_to_receiver, {:merge, self(), fields}})
      end
    end

    node
  end

  def append_child(parent, child, opts \\ []) do
    GenServer.call(parent.pid, {:append_child, child.pid, opts})
  end

  def append_child!(parent, child, opts \\ []) do
    GenServer.cast(parent.pid, {:append_child, child.pid, opts})
  end

  defp do_append_child(parent, child_pid, opts) do
    child = GenServer.call(child_pid, :get)
    all_descendants = [child.pid | :pg.get_members(child.pid)]
    parent = do_track(parent, all_descendants)
    child_nodes = List.insert_at(parent.child_nodes, -1, child.pid)

    child = GenServer.call(child.pid, {:put, :parent_element, parent.pid})
    
    if parent.node_type == 10 do
      Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.pid}))
    end

    if parent.owner_document do
      Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))
    end

    if receiver = opts[:receiver] do
      send(receiver, {:append_child, parent.pid, apply(child.__struct__, :encode, [child])})
    end

    struct(parent, child_nodes: child_nodes)
  end

  def encode(pid) when is_pid(pid) do
    node = GenServer.call(pid, :get)
    apply(node.__struct__, :encode, [node])
  end

  def encode(node) do
    %{
      pid: node.pid,
      node_type: node.node_type,
      parent_element: node.parent_element,
      owner_document: node.owner_document,
      child_nodes: Enum.map(node.child_nodes, &encode(&1)),
    }
  end

  def allowed_fields,
    do: []

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

  def compare_document_position(_node, _other_node) do

  end

  def contains?(node, other_node) do
    other_node.pid in :pg.get_members(node.pid)
  end

  def get_root_node(node, _opts \\ []) do
    if node.parent_element do
      get_root_node(GenServer.call(node.parent_element, :get))
    else
      node
    end
  end

  def has_child_nodes?(%{child_nodes: []}) do
    false
  end

  def has_child_nodes?(%{child_nodes: _child_nodes}) do
    true
  end

  def insert_before(parent, new_node, reference_node, opts \\ []) do
    GenServer.call(parent.pid, {:insert_before, new_node.pid, reference_node.pid, opts})
  end

  def insert_before!(parent, new_node, reference_node, opts \\ []) do
    GenServer.cast(parent.pid, {:insert_before, new_node.pid, reference_node.pid, opts})
  end

  defp do_insert_before(parent, new_node_pid, reference_node_pid, opts) do
    all_descendants = [new_node_pid | :pg.get_members(new_node_pid)]
    parent = do_track(parent, all_descendants)
    child_nodes = Enum.reduce(parent.child_nodes, [], fn
      ^reference_node_pid, child_nodes -> [reference_node_pid, new_node_pid | child_nodes]
      child_name, child_nodes -> [child_name | child_nodes]
    end)
    |> Enum.reverse()

    new_node = GenServer.call(new_node_pid, {:put, :parent_element, parent.pid})
    Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))

    if opts[:receiver] do
      send(opts[:receiver], {
        :insert_before,
        parent.pid,
        apply(new_node.__struct__, :encode, [new_node]),
        reference_node_pid
      })
    end

    struct(parent, child_nodes: child_nodes)
  end

  def is_default_namespace?(_node, _uri) do

  end

  def is_equal_node?(_node, _other_node) do
  end

  def is_same_node?(node, other_node) do
    node.pid == other_node.pid
  end

  def lookup_namespace_uri(node, prefix) do
    GenServer.call(node.pid, {:lookup_namespace_uri, prefix})
  end

  def lookup_prefix(node, namespace) do
    GenServer.call(node.pid, {:lookup_prefix, namespace})
  end

  def normalize(_node) do

  end

  def remove_child(parent, child, opts \\ []) do
    GenServer.call(parent.pid, {:remove_child, child.pid, opts})
  end

  def remove_child!(parent, child, opts \\ []) do
    GenServer.cast(parent.pid, {:remove_child, child.pid, opts})
  end

  defp do_remove_child(parent, child_pid, opts) do
    all_descendants = [child_pid | :pg.get_members(child_pid)]
    parent = do_untrack(parent, all_descendants)
    child_nodes = Enum.reject(parent.child_nodes, &(&1 == child_pid))

    if opts[:receiver] do
      send(opts[:receiver], {:remove_child, parent.pid, child_pid})
    end

    struct(parent, child_nodes: child_nodes)
  end

  def replace_child(parent, new_child, old_child, opts \\ []) do
    GenServer.call(parent.pid, {:replace_child, new_child.pid, old_child.pid, opts})
  end

  def replace_child!(parent, new_child, old_child, opts \\ []) do
    GenServer.cast(parent.pid, {:replace_child, new_child.pid, old_child.pid, opts})
  end

  defp do_replace_child(parent, new_child_pid, old_child_pid, opts) do
    all_descendants = [new_child_pid | :pg.get_members(new_child_pid)]

    parent =
      parent
      |> do_untrack([old_child_pid | :pg.get_members(old_child_pid)])
      |> do_track(all_descendants)

    child_nodes = Enum.map(parent.child_nodes, fn
      pid when pid == old_child_pid -> new_child_pid
      pid -> pid
    end)

    new_child = GenServer.call(new_child_pid, {:put, :parent_element, parent.pid})
    Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))

    if opts[:receiver] do
      send(opts[:receiver], {
        :replace_child,
        parent.pid,
        apply(new_child.__struct__, :encode, [new_child]),
        old_child_pid
      })
    end

    struct(parent, child_nodes: child_nodes)
  end

  defp do_track(parent, child_pid_or_children_pids) do
    if parent.parent_element, do: GenServer.call(parent.parent_element, {:track, child_pid_or_children_pids})
    :pg.join(parent.pid, child_pid_or_children_pids)

    parent
  end

  defp do_untrack(parent, child_pid_or_children_pids) do
    if parent.parent_element, do: GenServer.call(parent.parent_element, {:untrack, child_pid_or_children_pids})
    :pg.leave(parent.pid, child_pid_or_children_pids)

    parent
  end
end
