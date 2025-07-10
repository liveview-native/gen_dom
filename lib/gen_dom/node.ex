defmodule GenDOM.Node do
  @moduledoc """
  The DOM Node interface is an abstract base class upon which many other DOM API objects are based,
  thus letting those object types to be used similarly and often interchangeably.

  The `GenDOM.Node` module provides the base functionality for all DOM node types in the GenDOM library.
  It implements the core DOM Node specification as an Elixir GenServer process, allowing for stateful
  node management and hierarchical tree operations.

  ## Usage

  ```elixir
  # Create a new node
  node = GenDOM.Node.new([])

  # Use in other modules
  defmodule MyElement do
    use GenDOM.Node, [custom_field: "value"]
  end
  ```

  ## Features

  - Full DOM Node specification compliance
  - Process-based state management via GenServer
  - Hierarchical tree operations (appendChild, removeChild, etc.)
  - Node comparison and traversal methods
  - Namespace handling for XML documents
  """
  use GenServer

  @fields [
    assigns: %{},
    pid: nil,
    receiver: nil,
    is_element?: false,

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
    text_content: ""
  ]

  defmacro __using__(fields \\ []) do
    quote do
      use GenServer

      Module.register_attribute(__MODULE__, :fields, accumulate: true)

      @fields unquote(fields)
      @fields unquote(Macro.escape(@fields))

      # Flatten and resolve field conflicts (later fields override earlier ones)
      all_fields = List.flatten(@fields)
      |> Enum.reverse()
      |> Enum.uniq_by(fn 
        {key, _} -> key
        key -> key
      end)
      |> Enum.reverse()

      defstruct all_fields

      use GenDOM.QuerySelector

      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts)
      end

      def start(opts) do
        GenServer.start(__MODULE__, opts)
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
        case start(opts) do
          {:ok, pid} -> GenServer.call(pid, :get)
          _other -> {:error, "could not start"}
        end
      end
      defoverridable new: 1

      defdelegate append_child(node, child), to: GenDOM.Node
      defoverridable append_child: 2
      defdelegate append_child(node, child, opts), to: GenDOM.Node
      defoverridable append_child: 3
      defdelegate append_child!(node, child), to: GenDOM.Node
      defoverridable append_child!: 2
      defdelegate append_child!(node, child, opts), to: GenDOM.Node
      defoverridable append_child!: 3
      defdelegate clone_node(node), to: GenDOM.Node
      defoverridable clone_node: 1
      defdelegate clone_node(node, deep?), to: GenDOM.Node
      defoverridable clone_node: 2
      defdelegate compare_document_position(node, other_node), to: GenDOM.Node
      defoverridable compare_document_position: 2
      defdelegate contains?(node, other_node), to: GenDOM.Node
      defoverridable contains?: 2
      defdelegate has_child_nodes?(node), to: GenDOM.Node
      defoverridable has_child_nodes?: 1
      defdelegate insert_before(node, new_node, reference_node), to: GenDOM.Node
      defoverridable insert_before: 3
      defdelegate insert_before(node, new_node, reference_node, opts), to: GenDOM.Node
      defoverridable insert_before: 4
      defdelegate insert_before!(node, new_node, reference_node), to: GenDOM.Node
      defoverridable insert_before!: 3
      defdelegate insert_before!(node, new_node, reference_node, opts), to: GenDOM.Node
      defoverridable insert_before!: 4
      defdelegate is_default_namespace?(node, uri), to: GenDOM.Node
      defoverridable is_default_namespace?: 2
      defdelegate is_equal_node?(node, other_node), to: GenDOM.Node
      defoverridable is_equal_node?: 2
      defdelegate is_same_node?(node, other_node), to: GenDOM.Node
      defoverridable is_same_node?: 2
      defdelegate lookup_namespace_uri(node, prefix), to: GenDOM.Node
      defoverridable lookup_namespace_uri: 2
      defdelegate lookup_prefix(node, namespace), to: GenDOM.Node
      defoverridable lookup_prefix: 2
      defdelegate normalize(node), to: GenDOM.Node
      defoverridable normalize: 1
      defdelegate remove_child(node, child), to: GenDOM.Node
      defoverridable remove_child: 2
      defdelegate remove_child(node, child, opts), to: GenDOM.Node
      defoverridable remove_child: 3
      defdelegate remove_child!(node, child), to: GenDOM.Node
      defoverridable remove_child!: 2
      defdelegate remove_child!(node, child, opts), to: GenDOM.Node
      defoverridable remove_child!: 3
      defdelegate replace_child(node, new_child, old_child), to: GenDOM.Node
      defoverridable replace_child: 3
      defdelegate replace_child(node, new_child, old_child, opts), to: GenDOM.Node
      defoverridable replace_child: 4
      defdelegate replace_child!(node, new_child, old_child), to: GenDOM.Node
      defoverridable replace_child!: 3
      defdelegate replace_child!(node, new_child, old_child, opts), to: GenDOM.Node
      defoverridable replace_child!: 4

      defdelegate get(node), to: GenDOM.Node
      defoverridable get: 1
      defdelegate assign(node, assigns), to: GenDOM.Node
      defoverridable assign: 2
      defdelegate assign!(node, assigns), to: GenDOM.Node
      defoverridable assign!: 2
      defdelegate put(node, key, value), to: GenDOM.Node
      defoverridable put: 3
      defdelegate put!(node, key, value), to: GenDOM.Node
      defoverridable put!: 3
      defdelegate merge(node, fields), to: GenDOM.Node
      defoverridable merge: 2
      defdelegate merge!(node, fields), to: GenDOM.Node
      defoverridable merge!: 2

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

      def handle_call({:update, func}, from, node), do: GenDOM.Node.handle_call({:update, func}, from, node)

      defoverridable handle_call: 3

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

      def handle_cast({:update, func}, node), do: GenDOM.Node.handle_cast({:update, func}, node)

      defoverridable handle_cast: 2

      @impl true
      def handle_info({ref, msg, group, children}, node), do: GenDOM.Node.handle_info({ref, msg, group, children}, node)

      defoverridable handle_info: 2
    end
  end

  defstruct @fields

  def start_link(opts) do
    name = GenDOM.generate_name(__MODULE__)
    GenServer.start_link(__MODULE__, Keyword.put(opts, :name, name), name: name)
  end

  def start(opts) do
    name = GenDOM.generate_name(__MODULE__)
    GenServer.start(__MODULE__, Keyword.put(opts, :name, name), name: name)
  end

  @doc """
  Creates a new Node and returns the Node struct.

  This is a convenience function that calls start and then immediately gets the Node struct.

  ## Examples

      iex> node = GenDOM.Node.new([])
      iex> %GenDOM.Node{} = node
  """
  def new(opts \\ []) when is_list(opts) do
    case start(opts) do
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
    {:reply, node.pid, node}
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

  def handle_call({:insert_before, new_node, reference_node, opts}, _from, parent) do
    parent = do_insert_before(parent, new_node, reference_node, opts)
    {:reply, parent, parent}
  end

  def handle_call({:remove_child, child, opts}, _from, parent) do
    parent = do_remove_child(parent, child, opts)
    {:reply, parent, parent}
  end

  def handle_call({:replace_child, new_child, old_child, opts}, _from, parent) do
    parent = do_replace_child(parent, new_child, old_child, opts)
    {:reply, parent, parent}
  end

  def handle_call({:track, child_pid_or_children_pids}, _from, node) do
    IO.inspect(node.node_name)
    do_track(node, child_pid_or_children_pids)
    {:reply, node, node}
  end

  def handle_call({:untrack, child_pid_or_children_pids}, _from, node) do
    do_untrack(node, child_pid_or_children_pids)
    {:reply, node, node}
  end

  def handle_call({:update, func}, _from, node) when is_function(func) do
    func.(node)
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
    {:noreply, node}
  end

  def handle_cast({:replace_child, new_child, old_child, opts}, node) do
    node = do_replace_child(node, new_child.pid, old_child.pid, opts)
    {:noreply, node}
  end

  def handle_cast({:track, child_pid_or_children_pids}, node) do
    do_track(node, child_pid_or_children_pids)

    {:noreply, node}
  end

  def handle_cast({:untrack, child_pid_or_children_pids}, node) do
    do_untrack(node, child_pid_or_children_pids)

    {:noreply, node}
  end

  def handle_cast({:send_to_receiver, msg}, node) do
    send_to_receiver(node.receiver, msg)

    {:noreply, node}
  end

  def handle_cast({:update, func}, node) when is_function(func) do
    func.(node)
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

  def assign(node_pid, key, value) when is_atom(key),
    do: assign(node_pid, %{key => value})
  def assign(node_pid, assigns) do
    GenServer.call(node_pid, {:assign, assigns})
  end

  def assign!(node_pid, key, value) when is_atom(key),
    do: assign!(node_pid, %{key => value})
  def assign!(node_pid, assigns) do
    GenServer.cast(node_pid, {:assign, assigns})
  end

  def put(node_pid, field, value) do
    GenServer.call(node_pid, {:put, field, value})
  end

  def put!(node_pid, field, value) do
    GenServer.cast(node_pid, {:put, field, value})
  end

  defp do_put(node, field, value) do
    node = struct(node, %{field => value})

    allowed_fields = apply(node.__struct__, :allowed_fields, [])

    if field in allowed_fields  && node.owner_document do
      GenServer.cast(node.owner_document, {:send_to_receiver, {:put, self(), field, value}})
    end

    node
  end

  def merge(node_pid, fields) do
    GenServer.call(node_pid, {:merge, fields})
  end

  def merge!(node_pid, fields) do
    GenServer.cast(node_pid, {:merge, fields})
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

  @doc """
  Adds the specified child node as the last child to the current node.

  Returns the parent node PID after appending the child.
  This method implements the DOM `appendChild()` specification.

  ## Parameters

  - `parent_pid` - The PID of the parent node to append to
  - `child_pid` - The PID of the child node to append
  - `opts` - Optional keyword list of options

  ## Examples

      iex> parent = GenDOM.Node.new([])
      iex> child = GenDOM.Node.new([])
      iex> parent_pid = GenDOM.Node.append_child(parent.pid, child.pid)
      iex> updated_parent = GenDOM.Node.get(parent_pid)
      iex> length(updated_parent.child_nodes)
      1

  """
  def append_child(parent_pid, child_pid, opts \\ []) do
    child = get(child_pid)
    parent = GenServer.call(parent_pid, {:append_child, child, opts})
    parent.pid
  end

  def append_child!(parent_pid, child_pid, opts \\ []) do
    child = get(child_pid)
    GenServer.cast(parent_pid, {:append_child, child, opts})
  end

  defp do_append_child(parent, child, opts) do
    if child.parent_node,
      do: GenServer.call(child.parent_node, {:remove_child, child, []})

    all_descendants = [child.pid | :pg.get_members(child.pid)]

    do_track(parent, all_descendants)

    pos = length(parent.child_nodes)

    child_nodes = List.insert_at(parent.child_nodes, -1, child.pid)
    parent = struct(parent, child_nodes: child_nodes)

    update_parent_relationships(parent, child, pos, opts)
    update_node_relationships(child, parent, pos, opts)

    if parent.node_type == 10 do
      Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.pid}))
    end

    if parent.owner_document do
      Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))
    end

    send_to_receiver(opts[:receiver], {
      :append_child,
      parent.pid,
      apply(child.__struct__, :encode, [child])
    })

    parent
  end

  def encode(pid) when is_pid(pid) do
    node = GenServer.call(pid, :get)
    apply(node.__struct__, :encode, [node])
  end

  def encode(node) do
    # always force a fresh copy when encoding
    node = GenServer.call(node.pid, :get)
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

  @doc """
  Clone a Node, and optionally, all of its contents.

  By default, it clones the content of the node. This method implements the DOM `cloneNode()` specification.

  ## Parameters

  - `node_pid` - The PID of the node to clone
  - `deep?` - Boolean indicating whether descendants should be cloned (default: false)

  ## Examples

      node = GenDOM.Node.new([text_content: "Hello"])
      shallow_clone_pid = GenDOM.Node.clone_node(node.pid)
      deep_clone_pid = GenDOM.Node.clone_node(node.pid, true)

  """
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
    ]) |> Map.to_list()

    new_node = apply(node.__struct__, :new, [fields])

    if deep? do
      Enum.reduce(node.child_nodes, new_node.pid, fn(child_node_pid, new_node_pid) ->
        append_child(new_node_pid, clone_node(child_node_pid, deep?))
      end)
    else
      new_node.pid
    end
  end

  @doc """
  Compares the position of the current node against another node in any other document.

  This method implements the DOM `compareDocumentPosition()` specification.

  ## Parameters

  - `node_pid` - The PID of the reference node
  - `other_node_pid` - The PID of the node to compare position with

  ## Returns

  A bitmask indicating the relative position of the nodes.

  """
  def compare_document_position(_node, _other_node) do

  end

  @doc """
  Returns a boolean indicating whether a node is a descendant of the calling node.

  This method implements the DOM `contains()` specification by checking if the
  `other_node_pid` is present in the process group members of the current node.

  ## Parameters

  - `node_pid` - The PID of the node to check containment on
  - `other_node_pid` - The PID of the node to check if it's contained

  ## Examples

      iex> parent = GenDOM.Node.new([])
      iex> child = GenDOM.Node.new([])
      iex> parent_pid = GenDOM.Node.append_child(parent.pid, child.pid)
      iex> GenDOM.Node.contains?(parent_pid, child.pid)
      true

  """
  def contains?(pid, other_pid) do
    other_pid in :pg.get_members(pid)
  end

  @doc """
  Returns the context object's root which optionally includes the shadow root if it is available.

  This method implements the DOM `getRootNode()` specification by traversing up the parent chain
  until it finds a node with no parent.

  ## Parameters

  - `node_pid` - The PID of the node to get the root of
  - `opts` - Optional keyword list (unused currently)

  ## Examples

      root_pid = GenDOM.Node.get_root_node(some_nested_node.pid)

  """
  def get_root_node(node_pid, _opts \\ []) do
    node = get(node_pid)

    root_node = if node.parent_node do
      get_root_node(GenServer.call(node.parent_node, :get))
    else
      node
    end

    root_node.pid
  end

  @doc """
  Returns a boolean indicating whether the element has any child nodes.

  This method implements the DOM `hasChildNodes()` specification.

  ## Parameters

  - `node_pid` - The PID of the node to check for child nodes

  ## Examples

      iex> parent = GenDOM.Node.new([])
      iex> GenDOM.Node.has_child_nodes?(parent.pid)
      false
      iex> child = GenDOM.Node.new([])
      iex> parent_pid = GenDOM.Node.append_child(parent.pid, child.pid)
      iex> GenDOM.Node.has_child_nodes?(parent_pid)
      true

  """
  def has_child_nodes?(node_pid) do
    case get(node_pid) do
      %{child_nodes: []} -> false
      %{child_nodes: _child_nodes} -> true
    end
  end

  @doc """
  Inserts a Node before the reference node as a child of a specified parent node.

  This method implements the DOM `insertBefore()` specification.

  ## Parameters

  - `parent_pid` - The PID of the parent node to insert into
  - `new_node_pid` - The PID of the node to be inserted
  - `reference_node_pid` - The PID of the node before which new_node is inserted
  - `opts` - Optional keyword list of options

  ## Examples

      parent_pid = GenDOM.Node.insert_before(parent.pid, new_child.pid, existing_child.pid)

  """
  def insert_before(parent_pid, new_node_pid, reference_node_pid, opts \\ []) do
    new_node = get(new_node_pid)
    reference_node = get(reference_node_pid)
    parent = GenServer.call(parent_pid, {:insert_before, new_node, reference_node, opts})

    parent.pid
  end

  def insert_before!(parent, new_node_pid, reference_node_pid, opts \\ []) do
    new_node = get(new_node_pid)
    reference_node = get(reference_node_pid)
    GenServer.cast(parent.pid, {:insert_before, new_node, reference_node, opts})
  end

  defp do_insert_before(parent, new_node, %{pid: reference_node_pid}, opts) do
    if new_node.parent_node,
      do: GenServer.call(new_node.parent_node, {:remove_child, new_node, []})

    all_descendants = [new_node.pid | :pg.get_members(new_node.pid)]

    do_track(parent, all_descendants)

    {child_nodes, pos} = Enum.reduce(parent.child_nodes, {[], 0}, fn
      ^reference_node_pid, {child_nodes, pos} ->
        update_parent_relationships(parent, new_node, pos, opts)
        {[reference_node_pid, new_node.pid | child_nodes], pos + 1}

      child_pid, {child_nodes, pos} -> {[child_pid | child_nodes], pos + 1}
    end)

    update_node_relationships(new_node, parent, pos, opts)

    Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))

    send_to_receiver(opts[:receiver], {
      :insert_before,
      parent.pid,
      new_node,
      reference_node_pid
    })

    kill(reference_node_pid)
    struct(parent, child_nodes: Enum.reverse(child_nodes))
  end

  @doc """
  Accepts a namespace URI as an argument and returns a boolean value indicating whether 
  or not the namespace is the default namespace on the given node.

  This method implements the DOM `isDefaultNamespace()` specification.

  ## Parameters

  - `node_pid` - The PID of the node to check
  - `uri` - The namespace URI to test

  """
  def is_default_namespace?(_node, _uri) do

  end

  @doc """
  Returns a boolean value which indicates whether or not two nodes are of the same type 
  and all their defining data points match.

  This method implements the DOM `isEqualNode()` specification.

  ## Parameters

  - `node_pid` - The PID of the first node to compare
  - `other_node_pid` - The PID of the second node to compare

  """
  def is_equal_node?(_node, _other_node) do
  end

  @doc """
  Returns a boolean value indicating whether or not the two nodes are the same.

  This method implements the DOM `isSameNode()` specification by comparing process IDs.

  ## Parameters

  - `node_pid` - The PID of the first node to compare
  - `other_node_pid` - The PID of the second node to compare

  ## Examples

      GenDOM.Node.is_same_node?(node1.pid, node2.pid)
      # => true if they are the same node instance

  """
  def is_same_node?(node_pid, other_node_pid) do
    node_pid == other_node_pid
  end

  @doc """
  Accepts a prefix and returns the namespace URI associated with it on the given node.

  This method implements the DOM `lookupNamespaceURI()` specification. Returns `nil` if the prefix
  is not found.

  ## Parameters

  - `node_pid` - The PID of the node to lookup the namespace URI on
  - `prefix` - The namespace prefix to lookup

  ## Examples

      namespace_uri = GenDOM.Node.lookup_namespace_uri(node.pid, "xml")
      # => "http://www.w3.org/XML/1998/namespace"

  """
  def lookup_namespace_uri(node_pid, prefix) do
    GenServer.call(node_pid, {:lookup_namespace_uri, prefix})
  end

  @doc """
  Returns the prefix for a given namespace URI, if present, and `nil` if not.

  This method implements the DOM `lookupPrefix()` specification.

  ## Parameters

  - `node_pid` - The PID of the node to lookup the prefix on
  - `namespace` - The namespace URI to find the prefix for

  ## Examples

      prefix = GenDOM.Node.lookup_prefix(node.pid, "http://www.w3.org/XML/1998/namespace")
      # => "xml"

  """
  def lookup_prefix(node_pid, namespace) do
    GenServer.call(node_pid, {:lookup_prefix, namespace})
  end

  @doc """
  Puts the specified node and all of its subtree into a normalized form.

  This method implements the DOM `normalize()` specification. In a normalized subtree,
  no text nodes in the subtree are empty and there are no adjacent text nodes.

  ## Parameters

  - `node_pid` - The PID of the node to normalize

  ## Examples

      GenDOM.Node.normalize(node.pid)

  """
  def normalize(_node) do

  end

  @doc """
  Removes a child node from the DOM and returns the parent node PID.

  This method implements the DOM `removeChild()` specification.

  ## Parameters

  - `parent_pid` - The PID of the parent node to remove the child from
  - `child_pid` - The PID of the child node to remove
  - `opts` - Optional keyword list of options

  ## Examples

      parent_pid = GenDOM.Node.remove_child(parent.pid, child_to_remove.pid)

  """
  def remove_child(parent_pid, child_pid, opts \\ []) do
    child = get(child_pid)
    parent = GenServer.call(parent_pid, {:remove_child, child, opts})
    parent.pid
  end

  def remove_child!(parent_pid, child_pid, opts \\ []) do
    child = get(child_pid)
    GenServer.cast(parent_pid, {:remove_child, child, opts})
  end

  defp do_remove_child(parent, child, opts) do
    all_descendants = [child.pid | :pg.get_members(child.pid)]
    do_untrack(parent, all_descendants)

    child_nodes = Enum.reject(parent.child_nodes, &(&1 == child.pid))

    if opts[:receiver] do
      send(opts[:receiver], {:remove_child, parent.pid, child.pid})
    end

    struct(parent, child_nodes: child_nodes)
  end

  @doc """
  Replaces a child node within the given parent node.

  This method implements the DOM `replaceChild()` specification. The old child is removed
  and the new child is inserted in its place.

  ## Parameters

  - `parent_pid` - The PID of the parent node containing the child to replace
  - `new_child_pid` - The PID of the new node to replace the old child with
  - `old_child_pid` - The PID of the existing child to be replaced
  - `opts` - Optional keyword list of options

  ## Examples

      parent_pid = GenDOM.Node.replace_child(parent.pid, new_element.pid, old_element.pid)

  """
  def replace_child(parent_pid, new_child_pid, old_child_pid, opts \\ []) do
    new_child = get(new_child_pid)
    old_child = get(old_child_pid)
    parent = GenServer.call(parent_pid, {:replace_child, new_child, old_child, opts})
    parent.pid
  end

  def replace_child!(parent_pid, new_child_pid, old_child_pid, opts \\ []) do
    new_child = get(new_child_pid)
    old_child = get(old_child_pid)
    GenServer.cast(parent_pid, {:replace_child, new_child, old_child, opts})
  end

  defp do_replace_child(parent, new_child, %{pid: old_child_pid} = old_child, opts) do
    if new_child.parent_node,
      do: GenServer.call(new_child.parent_node, {:remove_child, new_child, []})

    all_descendants = [new_child.pid | :pg.get_members(new_child.pid)]

    do_untrack(parent, [old_child.pid | :pg.get_members(old_child.pid)])
    do_track(parent, all_descendants)

    {child_nodes, pos} = Enum.reduce(parent.child_nodes, {[], 0}, fn
      child_pid, {child_nodes, pos} when child_pid == old_child_pid ->
        update_parent_relationships(parent, new_child, pos, opts)
        {[new_child.pid | child_nodes], pos + 1}

      child_pid, {child_nodes, pos} -> {[child_pid | child_nodes], pos + 1}
    end)

    update_node_relationships(new_child, parent, pos, opts)

    # GenServer.cast(new_child.pid, {:put, :parent_element, parent.pid})
    Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))

    if opts[:receiver] do
      send(opts[:receiver], {
        :replace_child,
        parent.pid,
        apply(Map.get(new_child, :__struct__), :encode, [new_child]),
        old_child.pid
      })
    end

    struct(parent, child_nodes: Enum.reverse(child_nodes))
  end

  defp do_track(parent, child_pid_or_children_pids) do
    if parent.parent_node do
      GenServer.cast(parent.parent_node, {:track, child_pid_or_children_pids})
    end

    if parent.parent_element,
      do: GenServer.cast(parent.parent_element, {:track, child_pid_or_children_pids})

    :pg.join(parent.pid, child_pid_or_children_pids)
  end

  defp do_untrack(parent, child_pid_or_children_pids) do
    if parent.parent_node,
      do: GenServer.cast(parent.parent_node, {:untrack, child_pid_or_children_pids})

    if parent.parent_element,
      do: GenServer.cast(parent.parent_element, {:untrack, child_pid_or_children_pids})

    :pg.leave(parent.pid, child_pid_or_children_pids)
  end

  defp update_node_relationships(node, parent, pos, _opts) do
    parent_element = if parent.is_element?,
      do: parent.pid

    previous_sibling = if pos != 0 do
      previous_sibling = Enum.at(parent.child_nodes, pos - 1)
      GenServer.cast(previous_sibling, {:put, :next_sibling, node.pid})
      previous_sibling
    end

    next_pos = pos + 1
    next_sibling = if next_pos < length(parent.child_nodes),
      do: Enum.at(parent.child_nodes, next_pos)

    GenServer.cast(node.pid, {:merge, %{
      parent_node: parent.pid,
      parent_element: parent_element,
      previous_sibling: previous_sibling,
      next_sibling: next_sibling
    }})
  end

  defp update_parent_relationships(%{child_nodes: [node_pid], pid: parent_pid}, %{pid: node_pid}, 0, _opts) do
    GenServer.cast(parent_pid, {:merge, %{
      first_child: node_pid,
      last_child: node_pid
    }})
  end

  defp update_parent_relationships(parent, node, 0, _opts) do
    GenServer.cast(parent.pid, {:put, :first_child, node.pid})
  end

  defp update_parent_relationships(%{children: children} = parent, node, pos, _opts) when pos + 1 >= length(children) do
    GenServer.cast(parent.pid, {:put, :last_child, node.pid})
  end

  defp update_parent_relationships(_parent, _node, _pos, _opts) do
    :ok
  end

  defp send_to_receiver(pid, msg) when is_pid(pid) do
    send(pid, msg)
  end

  defp send_to_receiver(_other, _msg) do
    nil
  end

  defp kill(%{pid: pid}) do
    kill(pid)
  end

  defp kill(pid) when is_pid(pid) do
    Process.exit(pid, :kill)
  end
end
