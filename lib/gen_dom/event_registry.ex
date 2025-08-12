defmodule GenDOM.EventRegistry do
  @moduledoc false

  use GenServer

  alias GenDOM.Event

  defstruct [
    window: nil,
    listeners: %{},
    refs: %{}
  ]

  def add_listener(node_or_pid, type, listener, opts \\ []) when is_function(listener, 1) do
    node_pid = get_pid(node_or_pid)
    node = :sys.get_state(node_pid)
    GenServer.cast(node.event_registry, {:add_listener, node_pid, type, listener, opts})
  end

  def remove_listener(node_or_pid, type, listener, opts \\ []) when is_function(listener, 1) do
    node_pid = get_pid(node_or_pid)
    node = :sys.get_state(node_pid)
    GenServer.cast(node.event_registry, {:remove_listener, node_pid, type, listener, opts})
  end

  def dispatch(node_or_pid, event) do
    node_pid = get_pid(node_or_pid)
    node = :sys.get_state(node_pid)
    GenServer.cast(node.event_registry, {:dispatch, node_pid, event})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    {:ok, struct(%__MODULE__{}, window: opts[:window])}
  end

  @impl true
  def handle_cast({:add_listener, node_pid, type, listener, opts}, registry) do
    node_listeners = Map.get(registry.listeners, node_pid, %{})
    type_listeners = Map.get(node_listeners, type, [])
    listener_record = %{listener: listener, opts: opts, id: generate_id()}

    node_listeners = Map.put(node_listeners, type, List.insert_at(type_listeners, -1, listener_record))
    listeners = Map.put(registry.listeners, node_pid, node_listeners)

    refs = maybe_monitor_node(registry.refs, node_pid)

    {:noreply, Map.merge(registry, %{listeners: listeners, refs: refs})}
  end

  def handle_cast({:remove_listener, node_pid, type, listener, opts}, registry) do
    node_listeners = Map.get(registry.listeners, node_pid, %{})
    type_listeners =
      Map.get(node_listeners, type, [])
      |> Enum.reject(fn
        %{listener: ^listener} = listener_record ->
          opts_match?(opts, Map.get(listener_record, :opts, []))
        _other -> false
      end)

    node_listeners = case type_listeners do
      [] -> Map.delete(node_listeners, type)
      type_listeners -> Map.put(node_listeners, type, type_listeners)
    end

    listeners = case map_size(node_listeners) do
      0 -> Map.delete(registry.listeners, node_pid)
      _other -> Map.put(registry.listeners, node_pid, node_listeners)
    end

    {:noreply, Map.put(registry, :listeners, listeners)}
  end

  def handle_cast({:dispatch, node_pid, event}, registry) do
    do_dispatch(event, node_pid, registry)
    {:noreply, registry}
  end

  defp do_dispatch(event, nil, _registry) do
    event
  end

  defp do_dispatch(event, node_pid, registry) do
    node = GenServer.call(node_pid, :get)
    with {:ok, node_listeners} <- Map.fetch(registry.listeners, node_pid),
      {:ok, type_listeners} <- Map.fetch(node_listeners, event.type) do
        event
        |> capture_phase(type_listeners, registry)
        |> target_phase(node, registry)
        |> bubbling_phase(node, registry)
        |> default_actions_phase(node, registry)
        |> cleanup_phase(node, registry)
    else
      _err ->
        event
        |> target_phase(node, registry)
        |> bubbling_phase(node, registry)
        |> default_actions_phase(node, registry)
        |> cleanup_phase(node, registry)
    end

    event
  end

  @impl true
  def handle_info({:DOWN, ref, :process, pid, _reason}, registry) do
    Process.demonitor(ref)
    listeners = Map.delete(registry.listeners, pid)
    refs = Map.delete(registry.refs, pid)
    {:noreply, struct(registry, listeners: listeners, refs: refs)}
  end

  def opts_match?(opts_left, opts_right) do
    Keyword.get(opts_left, :capture, false) == Keyword.get(opts_right, :capture, false)
  end

  defp capture_phase(event, type_listeners, _registry) do
    Enum.reduce_while(type_listeners, event, fn(listener_record, event) ->
      if event.stop_immediate_propagation do
        {:halt, event}
      else
        {:cont, listener_record.listener.(event)}
      end
    end)
  end

  defp target_phase(event, _node, _registry) do
    event
  end

  defp bubbling_phase(%Event{stop_propagation: true} = event, _node, _registry) do
    event
  end

  defp bubbling_phase(%Event{stop_immediate_propagation: true} = event, _node, _registry) do
    event
  end

  defp bubbling_phase(%Event{bubbles: true} = event, node, registry) do
    do_dispatch(event, node.parent_node, registry)
  end

  defp bubbling_phase(event, _node, _registry) do
    event
  end

  defp default_actions_phase(event, node, _registry) do
    event = GenServer.call(node.pid, {:default_action, event.type, event})
  end

  defp cleanup_phase(event, _node, _registry) do
    event
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.encode64()
  end

  defp maybe_monitor_node(refs, node_pid) do
    if Map.has_key?(refs, node_pid) do
      refs
    else
      ref = Process.monitor(node_pid)
      Map.put(refs, node_pid, ref)
    end
  end

  defp get_pid(pid) when is_pid(pid) do
    pid
  end

  defp get_pid(%{pid: pid}) when is_pid(pid) do
    pid
  end
end
