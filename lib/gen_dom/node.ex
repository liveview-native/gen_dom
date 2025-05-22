defmodule GenDOM.Node do
  use GenServer

  @properties [
    name: nil,
    all_child_names: MapSet.new([]),
    assigns: %{},
    refs: %{},

    base_uri: nil,
    child_nodes: [],
    first_child: nil,
    is_connected: false,
    last_child: nil,
    next_sibling: nil,
    node_name: nil,
    node_type: nil,
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
        name = GenDOM.generate_name(__MODULE__)
        GenServer.start_link(__MODULE__, Keyword.put(opts, :name, name), name: name)
      end

      @impl true
      def init(opts) do
        {:ok, struct(%__MODULE__{}, opts)}
      end

      defdelegate append_child(node, child), to: GenDOM.Node
      defdelegate clone_node(node), to: GenDOM.Node
      defdelegate compare_document_position(node, other_node), to: GenDOM.Node
      defdelegate contains?(node, other_node), to: GenDOM.Node
      defdelegate has_child_nodes?(node), to: GenDOM.Node
      defdelegate insert_before(node, new_node, reference_node), to: GenDOM.Node
      defdelegate is_default_namespace?(node, uri), to: GenDOM.Node
      defdelegate is_equal_node?(node, other_node), to: GenDOM.Node
      defdelegate is_same_node?(node, other_node), to: GenDOM.Node
      defdelegate lookup_namespace_uri(node, prefix), to: GenDOM.Node
      defdelegate lookup_prefix(node, namespace), to: GenDOM.Node
      defdelegate normalize(node), to: GenDOM.Node
      defdelegate remove_child(node, child), to: GenDOM.Node
      defdelegate replace_child(node, new_child, old_child), to: GenDOM.Node

      defdelegate get(node), to: GenDOM.Node
      defdelegate assign(node, assigns), to: GenDOM.Node
      defdelegate put(node, key, value), to: GenDOM.Node
      defdelegate merge(node, fields), to: GenDOM.Node

      @impl true
      def handle_call(:get, from, node), do: GenDOM.Node.handle_call(:get, from, node)
      def handle_call({:assign, assigns}, from, node), do: GenDOM.Node.handle_call({:assign, assigns}, from, node)
      def handle_call({:merge, fields}, from, node), do: GenDOM.Node.handle_call({:merge, fields}, from, node)
      def handle_call({:put, field, value}, from, node), do: GenDOM.Node.handle_call({:put, field, value}, from, node)

      @impl true
      def handle_cast({:assign, assigns}, node), do: GenDOM.Node.handle_cast({:assign, assigns}, node)
      def handle_cast({:merge, fields}, node), do: GenDOM.Node.handle_cast({:merge, fields}, node)
      def handle_cast({:put, field, value}, node), do: GenDOM.Node.handle_cast({:put, field, value}, node)
      def handle_cast({:track, child}, node), do: GenDOM.Node.handle_cast({:track, child}, node)
      def handle_cast({:untrack, child}, node), do: GenDOM.Node.handle_cast({:untrack, child}, node)
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
  def new(opts) when is_list(opts) do
    case start_link(opts) do
      {:ok, pid} -> GenServer.call(pid, :get)
      _other -> {:error, "could not start"}
    end
  end

  @impl true
  def init(opts) do
    {:ok, struct(%__MODULE__{}, opts)}
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
    node = struct(node, fields)
    {:reply, node, node}
  end

  def handle_call({:put, field, value}, _from, node) do
    node = struct(node, %{field => value})
    {:reply, node, node}
  end

  @impl true
  def handle_cast({:assign, assigns}, node) when is_list(assigns),
    do: handle_cast({:assign, Map.new(assigns)}, node)

  def handle_cast({:assign, assigns}, node) when is_map(assigns) do
    node = struct(node, assigns: Map.merge(node.assigns, assigns))
    {:noreply, node}
  end

  def handle_cast({:merge, fields}, node) do
    node = struct(node, fields)
    {:noreply, node}
  end

  def handle_cast({:put, field, value}, node) do
    node = struct(node, %{field => value})
    {:noreply, node}
  end

  def handle_cast({:track, child}, node) do
    all_child_names = MapSet.union(node.all_child_names, MapSet.put(child.all_child_names, child.name))
    refs = monitor(node, child)
    if node.parent_element, do: GenServer.cast(node.parent_element, {:track, child})
    handle_cast({:merge, %{all_child_names: all_child_names, refs: refs}}, node)
  end

  def handle_cast({:untrack, child}, node) do
    all_child_names = MapSet.delete(node.all_child_names, child.name)

    refs = demonitor(node, child)
    if node.parent_element, do: GenServer.cast(node.parent_element, {:untrack, child})
    handle_cast({:merge, %{all_child_names: all_child_names, refs: refs}}, node)
  end

  def handle_cast({:DOWN, ref, :process, _object, _reason}, %{refs: refs} = node) when is_map_key(refs, ref) do
    Process.demonitor(ref)

    {child_name, refs} = Map.pop(node.refs, ref)

    child_nodes = Enum.reduce(node.child_nodes, [], fn
      ^child_name, child_nodes -> child_nodes
      child_name, child_nodes -> [child_name | child_nodes]
    end)

    handle_cast({:merge, %{child_nodes: child_nodes, refs: refs}}, node)
  end

  def get(name) when is_binary(name),
    do: name |> String.to_atom() |> get()
  def get(name) when is_atom(name) do
    GenServer.call(name, :get)
  end

  def assign(node, key, value) when is_atom(key),
    do: assign(node, %{key => value})
  def assign(node, assigns) do
    GenServer.call(node.name, {:assign, assigns})
  end

  def put(node, key, value) do
    GenServer.call(node.name, {:put, key, value})
  end

  def merge(node, fields) do
    GenServer.call(node.name, {:merge, fields})
  end

  def append_child(node, child) do
    track(node, child)
    child_nodes = List.insert_at(node.child_nodes, -1, child.name)

    GenServer.cast(child.name, {:put, :parent_element, node.name})
    GenServer.call(node.name, {:put, :child_nodes, child_nodes})
  end

  defp track(node, child) do
    GenServer.cast(node.name, {:track, child})
    node
  end

  defp untrack(node, child) do
    GenServer.cast(node.name, {:untrack, child})
    node
  end

  defp monitor(node, child) do
    pid = Process.whereis(child.name)
    ref = Process.monitor(pid)

    Map.put(node.refs, ref, child.name)
  end

  defp demonitor(node, child) do
    ref_entry = Enum.find(node.refs, fn {_ref, name} -> name == child.name end)

    case ref_entry do
      {ref, _child_name} ->
        Process.demonitor(ref)
        Map.delete(node.refs, ref)
      nil ->
        node.refs
    end
  end

  def clone_node(_node) do

  end

  def compare_document_position(_node, _other_node) do

  end

  def contains?(_node, _other_node) do

  end

  def has_child_nodes?(_node) do

  end

  def insert_before(node, new_node, %{name: reference_name}) do
    node = track(node, new_node)
    child_nodes = Enum.reduce(node.child_nodes, [], fn
      ^reference_name, child_nodes -> [reference_name, new_node.name | child_nodes]
      child_name, child_nodes -> [child_name | child_nodes]
    end)
    |> Enum.reverse()

    GenServer.cast(new_node.name, {:put, :parent_element, node.name})
    GenServer.call(node.name, {:put, :child_nodes, child_nodes})
  end

  def is_default_namespace?(_node, _uri) do

  end

  def is_equal_node?(_node, _other_node) do
  end

  def is_same_node?(node, other_node) do
    node.name == other_node.name
  end

  def lookup_namespace_uri(node, prefix) do
    GenServer.call(node.name, {:lookup_namespace_uri, prefix})
  end

  def lookup_prefix(node, namespace) do
    GenServer.call(node.name, {:lookup_prefix, namespace})
  end

  def normalize(_node) do

  end

  def remove_child(node, child) do
    node = untrack(node, child)
    child_nodes = Enum.reject(node.child_nodes, &(&1 == child.name))

    GenServer.call(node.name, {:put, :child_nodes, child_nodes})
  end

  def replace_child(node, new_child, old_child) do
    node =
      node
      |> untrack(old_child)
      |> track(new_child)

    child_nodes = Enum.map(node.child_nodes, fn
      name when name == old_child.name -> new_child.name
      name -> name
    end)

    GenServer.cast(new_child.name, {:put, :parent_element, node.name})
    GenServer.call(node.name, {:put, :child_nodes, child_nodes})
  end
end
