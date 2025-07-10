defmodule GenDOM.EventRegistry do
  @moduledoc false

  use GenServer

  defstruct [
    window: nil,
    listeners: %{}, # %{node_pid => %{event_type => [listener_records]}}
    cleanup_refs: %{} # %{node_pid => monitor_ref} for cleanup
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end
 
  @impl true
  def init(opts) do
    {:ok, struct(%__MODULE__{}, window: opts[:window])}
  end

  @impl true
  def handle_cast({:add_listener, node_pid, type, listener, options}, registry) do
    # Store listener centrally, monitor node for cleanup
    existing_listeners = get_in(registry.listeners, [node_pid, type]) || []
    listener_record = %{listener: listener, options: options, id: generate_id()}
    
    # Build updated listeners structure
    node_listeners = Map.get(registry.listeners, node_pid, %{})
    updated_node_listeners = Map.put(node_listeners, type, [listener_record | existing_listeners])
    updated_listeners = Map.put(registry.listeners, node_pid, updated_node_listeners)
    
    # Monitor node for cleanup
    cleanup_refs = maybe_monitor_node(registry.cleanup_refs, node_pid)
    
    {:noreply, struct(registry, listeners: updated_listeners, cleanup_refs: cleanup_refs)}
  end

  def handle_cast({:remove_listener, node_pid, type, listener, options}, registry) do
    case get_in(registry.listeners, [node_pid, type]) do
      nil -> 
        {:noreply, registry}
      
      listeners ->
        # Remove matching listener (same listener and options)
        updated_listeners = Enum.reject(listeners, fn record ->
          record.listener == listener and options_match?(record.options, options)
        end)
        
        # Update registry
        listeners_map = if updated_listeners == [] do
          # Remove empty type key
          node_listeners = Map.delete(registry.listeners[node_pid] || %{}, type)
          if node_listeners == %{} do
            # Remove node entirely if no listeners left
            Map.delete(registry.listeners, node_pid)
          else
            Map.put(registry.listeners, node_pid, node_listeners)
          end
        else
          # Update the listeners for this type
          node_listeners = Map.put(registry.listeners[node_pid], type, updated_listeners)
          Map.put(registry.listeners, node_pid, node_listeners)
        end
        
        {:noreply, struct(registry, listeners: listeners_map)}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, registry) do
    # Node died, clean up its listeners
    listeners = Map.delete(registry.listeners, pid)
    cleanup_refs = Map.delete(registry.cleanup_refs, pid)
    {:noreply, struct(registry, listeners: listeners, cleanup_refs: cleanup_refs)}
  end

  # Helper to match options based on DOM spec
  defp options_match?(record_options, remove_options) do
    # DOM spec: only 'capture' matters for removal matching
    Map.get(record_options, :capture, false) == Map.get(remove_options, :capture, false)
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16) |> Base.encode64()
  end

  defp maybe_monitor_node(cleanup_refs, node_pid) do
    if Map.has_key?(cleanup_refs, node_pid) do
      cleanup_refs
    else
      ref = Process.monitor(node_pid)
      Map.put(cleanup_refs, node_pid, ref)
    end
  end
end
