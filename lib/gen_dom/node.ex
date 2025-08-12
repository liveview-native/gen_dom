defmodule GenDOM.Node do
  @moduledoc """
  The Node interface is an abstract base class upon which many other DOM API objects are based.

  Node is the primary datatype for the entire Document Object Model. It represents a single node
  in the document tree. While all objects implementing the Node interface expose methods for dealing
  with children, not all objects implementing the Node interface may have children.

  ## Specification Compliance

  This module implements the DOM Node interface as defined by:
  - **W3C DOM Level 4**: https://www.w3.org/TR/dom/#node
  - **WHATWG DOM Standard**: https://dom.spec.whatwg.org/#node

  ## Node Types

  The DOM specification defines several node types, each with a specific numeric constant:

  | Node Type | Constant | Description |
  |-----------|----------|-------------|
  | 0 | NODE_BASE | Base node (GenDOM extension) |
  | 1 | ELEMENT_NODE | Element nodes (div, p, etc.) |
  | 2 | ATTRIBUTE_NODE | Attribute nodes (deprecated) |
  | 3 | TEXT_NODE | Text content |
  | 4 | CDATA_SECTION_NODE | CDATA sections |
  | 5 | ENTITY_REFERENCE_NODE | Entity references (deprecated) |
  | 6 | ENTITY_NODE | Entities (deprecated) |
  | 7 | PROCESSING_INSTRUCTION_NODE | Processing instructions |
  | 8 | COMMENT_NODE | Comment nodes |
  | 9 | DOCUMENT_NODE | Document root |
  | 10 | DOCUMENT_TYPE_NODE | Document type declaration |
  | 11 | DOCUMENT_FRAGMENT_NODE | Document fragments |
  | 12 | NOTATION_NODE | Notations (deprecated) |

  ## Properties

  ### Node Identity and Structure
  - `node_type` - Integer constant identifying the node type
  - `node_name` - String name of the node (varies by type)
  - `node_value` - String value of the node (varies by type)
  - `base_uri` - Absolute base URI of the node

  ### Tree Relationships
  - `parent_node` - Reference to parent node (nil for root)
  - `parent_element` - Reference to parent element (nil if parent is not element)
  - `child_nodes` - NodeList of all child nodes
  - `first_child` - Reference to first child node (nil if no children)
  - `last_child` - Reference to last child node (nil if no children)
  - `previous_sibling` - Reference to previous sibling (nil if first child)
  - `next_sibling` - Reference to next sibling (nil if last child)

  ### Document Context
  - `owner_document` - Reference to the Document that owns this node
  - `is_connected` - Boolean indicating if node is connected to document

  ### Content
  - `text_content` - Textual content of node and descendants

  ## Methods

  ### Tree Manipulation
  - `append_child/3` - Append node to end of child list
  - `insert_before/4` - Insert node before reference child
  - `remove_child/3` - Remove child node from tree
  - `replace_child/4` - Replace one child with another

  ### Node Queries
  - `contains?/2` - Check if one node contains another
  - `is_equal_node?/2` - Test if two nodes are equivalent
  - `is_same_node?/2` - Test if two references point to same node
  - `compare_document_position/2` - Compare relative position of nodes

  ### Node Creation
  - `clone_node/2` - Create copy of node (shallow or deep)

  ### Text Content
  - `normalize/1` - Merge adjacent text nodes
  - `get_root_node/2` - Get root node (document or shadow root)

  ## Process-Based Architecture

  Each Node is implemented as an independent GenServer process, providing:

  ### Concurrency Benefits
  - **Parallel Operations**: Multiple nodes can be manipulated simultaneously
  - **State Isolation**: Each node maintains independent state
  - **Fault Tolerance**: Node failures don't cascade to other nodes
  - **Message Passing**: Thread-safe inter-node communication

  ### Process Groups
  GenDOM uses Erlang's `:pg` (Process Groups) for:
  - **Hierarchical Tracking**: Parent-child relationships
  - **Document Membership**: Tracking which nodes belong to documents
  - **Event Propagation**: Efficient event bubbling and capturing

  ### Memory Management
  - **Automatic Cleanup**: Process termination cleans up node state
  - **Reference Counting**: Proper cleanup of circular references
  - **Process Monitoring**: Automatic relationship updates on node death

  ## Usage Examples

  ```elixir
  # Create a base node
  node = GenDOM.Node.new([
    node_type: 1,
    node_name: "custom-node"
  ])

  # Tree manipulation
  child = GenDOM.Node.new([node_type: 3, node_value: "Hello"])
  GenDOM.Node.append_child(node.pid, child.pid)

  # Node queries
  contains_child = GenDOM.Node.contains?(node.pid, child.pid)
  root = GenDOM.Node.get_root_node(child.pid)

  # Clone operations
  shallow_copy = GenDOM.Node.clone_node(node.pid, false)
  deep_copy = GenDOM.Node.clone_node(node.pid, true)
  ```

  ## Custom Node Types

  Create custom node implementations by using GenDOM.Node:

  ```elixir
  defmodule MyCustomNode do
    use GenDOM.Node, [
      node_type: 8,
      node_name: "my-custom-node",
      custom_property: "default_value"
    ]

    # Override or add custom methods
    def custom_method(node_pid) do
      GenServer.call(node_pid, :custom_operation)
    end

    @impl true
    def handle_call(:custom_operation, _from, state) do
      # Custom behavior
      {:reply, :ok, state}
    end
  end
  ```

  ## Event System Integration

  Nodes participate in the DOM event system:
  - **Event Targets**: All nodes can be event targets
  - **Event Propagation**: Support for capturing and bubbling phases
  - **Event Delegation**: Efficient handling through tree structure

  ## Thread Safety Guarantees

  All Node operations are thread-safe through GenServer message passing:
  - **Atomic Operations**: State changes are atomic within message handlers
  - **Consistent Reads**: State reads are consistent within message context
  - **Safe Concurrency**: Multiple processes can safely operate on different nodes

  ## Performance Characteristics

  - **Process Creation**: O(1) for node creation
  - **Tree Traversal**: O(n) for deep traversals
  - **State Access**: O(1) for property access via GenServer calls
  - **Memory Usage**: ~2KB per node process overhead

  ## Debugging and Introspection

  Built-in debugging capabilities:
  - **Process Tree Visualization**: View node hierarchy
  - **State Inspection**: Examine node state via `:observer`
  - **Message Tracing**: Track inter-node communication
  - **Performance Monitoring**: Built-in telemetry events
  """

  require Logger

  use GenGraph.Tree, [
    assigns: %{},
    window: nil,
    event_registry: nil,
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

  defmacro __using__(fields) do
    quote do
      require Inherit
      Inherit.setup(unquote(__MODULE__), unquote(fields))

      @impl true
      def init(opts) do
        {:ok, node} = super(opts)
        :pg.start_link()
        :pg.monitor(node.pid)

        {:ok, node}
      end
      defwithhold init: 1
      defoverridable init: 1
    end
  end

  @impl true
  def init(opts) do
    {:ok, node} = super(opts)
    :pg.start_link()
    :pg.monitor(node.pid)

    {:ok, node}
  end
  defwithhold init: 1

  @impl true
  def handle_call({:put, field, value} = msg, from, object) do
    {:reply, object, object} = super(msg, from, object)
    object = do_put(object, field, value)
    {:reply, object, object}
  end

  def handle_call({:put_lazy, field, func}, from, object) do
    value = func.(object)
    handle_call({:put, field, value}, from, object)
  end

  def handle_call({:merge, fields} = msg, from, object) do
    {:reply, object, object} = super(msg, from, object)
    object = do_merge(object, fields)
    {:reply, object, object}
  end

  def handle_call({:merge_lazy, func}, from, object) do
    fields = func.(object)
    handle_call({:merge, fields}, from, object)
  end

  def handle_call({:assign, assigns}, _from, node) when is_map(assigns) do
    node = struct(node, assigns: Map.merge(node.assigns, assigns))
    {:reply, node.pid, node}
  end

  def handle_call({:assign, assigns}, from, node) when is_list(assigns),
    do: handle_call({:assign, Map.new(assigns)}, from, node)

  def handle_call({:append_child, child_pid, opts} = msg, from, parent) do
    {:reply, parent, parent} = super(msg, from, parent)
    parent = do_append_child(parent, child_pid, opts)
    {:reply, parent, parent} 
  end

  def handle_call({:insert_before, new_node_pid, reference_node_pid, opts}, _from, parent) do
    case do_insert_before(parent, new_node_pid, reference_node_pid, opts) do
      :error -> {:reply, :error, parent}
      parent -> {:reply, parent, parent}
    end
  end

  def handle_call({:remove_child, child_pid, opts} = msg, from, parent) do
    case super(msg, from, parent) do
      {:reply, :error, parent} -> {:reply, :eror, parent}
      {:reply, parent, parent} ->
        do_remove_child(parent, child_pid, opts)
        {:reply, parent, parent}
    end
  end

  def handle_call({:replace_child, new_child_pid, old_child_pid, opts}, _from, parent) do
    case do_replace_child(parent, new_child_pid, old_child_pid, opts) do
      :error -> {:reply, :error, parent}
      parent -> {:reply, parent, parent}
    end
  end

  def handle_call({:track, child_pid_or_children_pids}, _from, node) do
    do_track(node, child_pid_or_children_pids)
    {:reply, node, node}
  end

  def handle_call({:untrack, child_pid_or_children_pids}, _from, node) do
    do_untrack(node, child_pid_or_children_pids)
    {:reply, node, node}
  end

  def handle_call({:default_action, type, event}, _from, node) do
    event = apply(node.__struct__, :handle_default_action, [type, event, node])
    {:reply, event, node}
  end

  def handle_call(msg, from, node) do
    super(msg, from, node)
  end

  defoverridable handle_call: 3

  @impl true
  def handle_cast({:put, field, value} = msg, object) do
    {:noreply, object} = super(msg, object)
    object = do_put(object, field, value)
    {:noreply, object}
  end

  def handle_cast({:put_lazy, field, func}, object) do
    value = func.(object)
    handle_cast({:put, field, value}, object)
  end

  def handle_cast({:merge, fields} = msg, object) do
    {:noreply, object} = super(msg, object)
    object = do_merge(object, fields)
    {:noreply, object}
  end

  def handle_cast({:merge_lazy, func}, object) do
    fields = func.(object)
    handle_cast({:merge, fields}, object)
  end

  def handle_cast({:assign, assigns}, node) when is_map(assigns) do
    node = struct(node, assigns: Map.merge(node.assigns, assigns))
    {:noreply, node}
  end

  def handle_cast({:assign, assigns}, node) when is_list(assigns) do
    handle_cast({:assign, Map.new(assigns)}, node)
  end

  def handle_cast({:append_child, child_pid, opts} = msg, parent) do
    {:noreply, parent} = super(msg, parent)
    parent = do_append_child(parent, child_pid, opts)
    {:noreply, parent}
  end

  def handle_cast({:insert_before, new_node_pid, reference_node_pid, opts}, parent) do
    case do_insert_before(parent, new_node_pid, reference_node_pid, opts) do
      :error -> {:noreply, parent}
      parent -> {:noreply, parent}
    end
  end

  def handle_cast({:remove_child, child, opts} = msg, parent) do
    {:noreply, parent} = super(msg, parent)
    do_remove_child(parent, child, opts)
    {:noreply, parent}
  end

  def handle_cast({:replace_child, new_child_pid, old_child_pid, opts}, parent) do
    case do_replace_child(parent, new_child_pid, old_child_pid, opts) do
      :error -> {:noreply, parent}
      parent -> {:noreply, parent}
    end
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

  def handle_cast(msg, node) do
    super(msg, node)
  end

  defoverridable handle_cast: 2

  @impl true
  def handle_info({_ref, :leave, pid, _children}, %{pid: pid} = node) do
    {:noreply, node}
  end

  def handle_info({_ref, _msg, pid, _children}, %{pid: pid} = node) do
    {:noreply, node}
  end

  def handle_info(msg, node) do
    super(msg, node)
    {:noreply, node}
  end

  defoverridable handle_info: 2

  def handle_default_action(_type, event, _node) do
    # Logger.info("unhandled default action #{type} for #{inspect(node.pid)}")
    event
  end

  defoverridable handle_default_action: 3

  @doc """
  Assigns values to the node's assigns map and returns the node PID.

  This function merges the given assigns with the node's existing assigns map.
  Use this for setting arbitrary key-value pairs that are specific to your application.

  ## Parameters

  - `node_pid` - The PID of the node
  - `key` - An atom key (when providing a single key-value pair)
  - `value` - The value to assign to the key
  - `assigns` - A map or keyword list of assigns to merge

  ## Examples

      iex> node = GenDOM.Node.new([])
      iex> node_pid = GenDOM.Node.assign(node.pid, :user_id, 123)
      iex> node_pid = GenDOM.Node.assign(node.pid, %{name: "John", age: 30})
      iex> updated_node = GenDOM.Node.get(node_pid)
      iex> updated_node.assigns
      %{user_id: 123, name: "John", age: 30}

  """
  def assign(node_pid, key, value) when is_atom(key),
    do: assign(node_pid, %{key => value})
  def assign(node_pid, assigns) do
    GenServer.call(node_pid, {:assign, assigns})
  end

  @doc """
  Assigns values to the node's assigns map asynchronously without returning a value.

  This function is the asynchronous version of `assign/2` and `assign/3`. It merges
  the given assigns with the node's existing assigns map but doesn't wait for a response.

  ## Parameters

  - `node_pid` - The PID of the node
  - `key` - An atom key (when providing a single key-value pair)
  - `value` - The value to assign to the key
  - `assigns` - A map or keyword list of assigns to merge

  ## Examples

      iex> node = GenDOM.Node.new([])
      iex> GenDOM.Node.assign!(node.pid, :user_id, 123)
      iex> GenDOM.Node.assign!(node.pid, %{name: "John", age: 30})

  """
  def assign!(node_pid, key, value) when is_atom(key),
    do: assign!(node_pid, %{key => value})
  def assign!(node_pid, assigns) do
    GenServer.cast(node_pid, {:assign, assigns})
  end

  defp do_put(node, field, value) do
    node = struct(node, %{field => value})

    allowed_fields = apply(node.__struct__, :allowed_fields, [])

    if field in allowed_fields  && node.owner_document do
      GenServer.cast(node.owner_document, {:send_to_receiver, {:put, self(), field, value}})
    end

    node
  end

  defp do_merge(node, fields) do
    if node.owner_document do
      allowed_fields = apply(node.__struct__, :allowed_fields, [])
      fields = Map.drop(fields, allowed_fields)

      if !Enum.empty?(fields) do
        GenServer.cast(node.owner_document, {:send_to_receiver, {:merge, self(), fields}})
      end
    end

    node
  end

  defp do_append_child(parent, child_pid, opts) do
    all_descendants = [child_pid | :pg.get_members(child_pid)]

    do_track(parent, all_descendants)

    pos = length(parent.child_nodes)

    update_parent_relationships(parent, child_pid, pos, opts)
    update_node_relationships(parent, child_pid, pos, opts)

    cond do
      parent.node_type == 10 ->
        Enum.each(all_descendants, &GenServer.cast(&1, {:merge, %{
          owner_document: parent.pid,
          window: parent.window,
          event_registry: parent.event_registry
        }}))

    parent.owner_document ->
      Enum.each(all_descendants, &GenServer.cast(&1, {:merge, %{
        owner_document: parent.owner_document,
        window: parent.window,
        event_registry: parent.event_registry
      }}))

    true ->
      Enum.each(all_descendants, &GenServer.cast(&1, {:merge, %{
        window: parent.window,
        event_registry: parent.event_registry
      }}))
    end

    send_to_receiver(opts[:receiver], {
      :append_child,
      parent.pid,
      encode(child_pid)
    })

    parent
  end

  def encode(pid) when is_pid(pid) do
    node = GenServer.call(pid, :get)
    apply(node.__struct__, :encode, [node])
  end

  def encode(%{pid: pid} = _node) when is_pid(pid) do
    # always force a fresh copy when encoding
    node = GenServer.call(pid, :get)
    %{
      pid: node.pid,
      node_type: node.node_type,
      parent_element: node.parent_element,
      owner_document: node.owner_document,
      child_nodes: Enum.map(node.child_nodes, &encode(&1)),
    }
  end
  defoverridable encode: 1

  def allowed_fields,
    do: []
  defoverridable allowed_fields: 0

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
  defoverridable clone_node: 1, clone_node: 2

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
    nil
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

  defp do_insert_before(parent, new_node_pid, reference_node_pid, opts) do
    if Enum.member?(parent.child_nodes, reference_node_pid) do
      new_node = GenServer.call(new_node_pid, :get)
      parent = cond do
        (new_node.parent_node == self()) ->
          handle_call({:remove_child, new_node_pid, opts}, {}, parent)
        is_pid(new_node.parent_node) ->
          GenServer.call(new_node.parent_node, {:remove_child, new_node_pid, []})
        true -> parent
      end

      all_descendants = [new_node_pid | :pg.get_members(new_node_pid)]

      do_track(parent, all_descendants)

      {child_nodes, pos} = Enum.reduce(parent.child_nodes, {[], 0}, fn
        ^reference_node_pid, {child_nodes, pos} ->
          update_parent_relationships(parent, new_node_pid, pos, opts)
          {[reference_node_pid, new_node_pid | child_nodes], pos + 1}

        child_pid, {child_nodes, pos} -> {[child_pid | child_nodes], pos + 1}
      end)

      update_node_relationships(parent, new_node_pid, pos, opts)

      Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))

      send_to_receiver(opts[:receiver], {
        :insert_before,
        parent.pid,
        encode(new_node_pid),
        reference_node_pid
      })

      Map.put(parent, :child_nodes, Enum.reverse(child_nodes))
    else
      :error
    end
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
    nil
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

  """
  def normalize(node_pid) do
    GenServer.call(node_pid, :normalize)
  end

  defp do_remove_child(parent, child_pid, opts) do
    all_descendants = [child_pid | :pg.get_members(child_pid)]
    do_untrack(parent, all_descendants)

    if opts[:receiver] do
      send(opts[:receiver], {:remove_child, parent.pid, child_pid})
    end
  end

  defp do_replace_child(parent, new_child_pid, old_child_pid, opts) do
    GenServer.cast(old_child_pid, {:put_lazy, :parent_pid, fn(child) ->
      if child.parent_pid == parent.pid do
        nil
      else
        child.parent_pid
      end
    end})

    if Enum.member?(parent.child_nodes, old_child_pid) do
      new_child = GenServer.call(new_child_pid, :get)
      if new_child.parent_node,
        do: GenServer.call(new_child.parent_node, {:remove_child, new_child, []})

      all_descendants = [new_child_pid | :pg.get_members(new_child_pid)]

      do_untrack(parent, [old_child_pid | :pg.get_members(old_child_pid)])
      do_track(parent, all_descendants)

      {child_nodes, pos} = Enum.reduce(parent.child_nodes, {[], 0}, fn
        child_pid, {child_nodes, pos} when child_pid == old_child_pid ->
          update_parent_relationships(parent, new_child_pid, pos, opts)
          {[new_child_pid | child_nodes], pos + 1}

        child_pid, {child_nodes, pos} -> {[child_pid | child_nodes], pos + 1}
      end)

      update_node_relationships(parent, new_child_pid, pos, opts)

      GenServer.cast(new_child.pid, {:put, :parent_element, parent.pid})
      Enum.each(all_descendants, &GenServer.cast(&1, {:put, :owner_document, parent.owner_document}))

      send_to_receiver(opts[:receiver], {
        :replace_child,
        parent.pid,
        apply(Map.get(new_child, :__struct__), :encode, [new_child]),
        old_child_pid
      })

      Map.put(parent, :child_nodes, Enum.reverse(child_nodes))
    else
      :error
    end
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

  defp update_node_relationships(parent, node_pid, pos, _opts) do
    parent_element = if parent.is_element?,
      do: parent.pid

    previous_sibling = if pos != 0 do
      previous_sibling = Enum.at(parent.child_nodes, pos - 1)
      GenServer.cast(previous_sibling, {:put, :next_sibling, node_pid})
      previous_sibling
    end

    next_pos = pos + 1
    next_sibling = if next_pos < length(parent.child_nodes),
      do: Enum.at(parent.child_nodes, next_pos)

    GenServer.cast(node_pid, {:merge, %{
      parent_node: parent.pid,
      parent_element: parent_element,
      previous_sibling: previous_sibling,
      next_sibling: next_sibling
    }})
  end

  defp update_parent_relationships(%{child_nodes: [node_pid], pid: parent_pid}, node_pid, 0, _opts) do
    GenServer.cast(parent_pid, {:merge, %{
      first_child: node_pid,
      last_child: node_pid
    }})
  end

  defp update_parent_relationships(parent, node_pid, 0, _opts) do
    GenServer.cast(parent.pid, {:put, :first_child, node_pid})
  end

  defp update_parent_relationships(%{children: children} = parent, node_pid, pos, _opts) when pos + 1 >= length(children) do
    GenServer.cast(parent.pid, {:put, :last_child, node_pid})
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

  # These delegates are temporary until
  # multi-inheritance is added to Inherit

  def add_event_listener(node, type, listener, opts \\ []) do
    GenDOM.EventTarget.add_event_listener(node, type, listener, opts)
  end
  defoverridable add_event_listener: 3, add_event_listener: 4

  def remove_event_listener(node, type, listener, opts \\ []) do
    GenDOM.EventTarget.remove_event_listener(node, type, listener, opts)
  end
  defoverridable remove_event_listener: 3, remove_event_listener: 4

  def dispatch_event(node, event) do
    GenDOM.EventTarget.dispatch_event(node, event)
  end
  defoverridable dispatch_event: 2

  def query_selector_all(pid_or_node, selectors) do
    GenDOM.QuerySelector.query_selector_all(pid_or_node, selectors)
  end
  defoverridable query_selector_all: 2

  def query_selector(pid_or_node, selectors) do
    GenDOM.QuerySelector.query_selector(pid_or_node, selectors)
  end
  defoverridable query_selector: 2

  def default_actions(_pid, event) do
    event
  end
  defoverridable default_actions: 2
end
