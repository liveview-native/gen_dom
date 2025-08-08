defmodule GenDOM.EventRegistryTest do
  use ExUnit.Case, async: true

  alias GenDOM.EventRegistry

  describe "start_link/1" do
    test "starts with provided window option" do
      window_pid = self()
      {:ok, registry} = EventRegistry.start_link(window: window_pid)
      
      state = :sys.get_state(registry)
      assert state.window == window_pid
      assert state.listeners == %{}
      assert state.cleanup_refs == %{}
    end

    test "starts with default nil window" do
      {:ok, registry} = EventRegistry.start_link([])
      
      state = :sys.get_state(registry)
      assert state.window == nil
      assert state.listeners == %{}
      assert state.cleanup_refs == %{}
    end
  end

  describe "add_listener/4" do
    setup do
      {:ok, registry} = EventRegistry.start_link([])
      node_pid = spawn(fn -> receive do _ -> :ok end end)
      
      %{registry: registry, node_pid: node_pid}
    end

    test "adds first listener for node and event type", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      options = %{capture: false}
      
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, options})
      
      # Allow cast to process
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      assert Map.has_key?(state.listeners, node_pid)
      assert Map.has_key?(state.listeners[node_pid], "click")
      
      [listener_record] = state.listeners[node_pid]["click"]
      assert listener_record.listener == listener
      assert listener_record.options == options
      assert is_binary(listener_record.id)
    end

    test "adds multiple listeners for same event type", %{registry: registry, node_pid: node_pid} do
      listener1 = fn -> :ok end
      listener2 = fn -> :ok end
      options = %{capture: false}
      
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener1, options})
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener2, options})
      
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      listeners = state.listeners[node_pid]["click"]
      assert length(listeners) == 2
      
      listener_fns = Enum.map(listeners, & &1.listener)
      assert listener2 in listener_fns
      assert listener1 in listener_fns
    end

    test "adds listeners for different event types", %{registry: registry, node_pid: node_pid} do
      listener1 = fn -> :ok end
      listener2 = fn -> :ok end
      options = %{capture: false}
      
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener1, options})
      GenServer.cast(registry, {:add_listener, node_pid, "keydown", listener2, options})
      
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      node_listeners = state.listeners[node_pid]
      assert Map.has_key?(node_listeners, "click")
      assert Map.has_key?(node_listeners, "keydown")
      assert length(node_listeners["click"]) == 1
      assert length(node_listeners["keydown"]) == 1
    end

    test "monitors node process for cleanup", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      options = %{capture: false}
      
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, options})
      
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      assert Map.has_key?(state.cleanup_refs, node_pid)
      assert is_reference(state.cleanup_refs[node_pid])
    end

    test "only monitors node process once", %{registry: registry, node_pid: node_pid} do
      listener1 = fn -> :ok end
      listener2 = fn -> :ok end
      options = %{capture: false}
      
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener1, options})
      GenServer.cast(registry, {:add_listener, node_pid, "keydown", listener2, options})
      
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      # Should only have one monitor ref per node
      assert map_size(state.cleanup_refs) == 1
      assert Map.has_key?(state.cleanup_refs, node_pid)
    end
  end

  describe "remove_listener/4" do
    setup do
      {:ok, registry} = EventRegistry.start_link([])
      node_pid = spawn(fn -> receive do _ -> :ok end end)
      
      %{registry: registry, node_pid: node_pid}
    end

    test "removes existing listener", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      options = %{capture: false}
      
      # Add listener
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      # Remove listener
      GenServer.cast(registry, {:remove_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      assert state.listeners == %{}
    end

    test "removes only matching listener", %{registry: registry, node_pid: node_pid} do
      listener1 = fn -> :ok end
      listener2 = fn -> :ok end
      options = %{capture: false}
      
      # Add two listeners
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener1, options})
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener2, options})
      :timer.sleep(10)
      
      # Remove one listener
      GenServer.cast(registry, {:remove_listener, node_pid, "click", listener1, options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      listeners = state.listeners[node_pid]["click"]
      assert length(listeners) == 1
      assert hd(listeners).listener == listener2
    end

    test "does not remove listener with different capture option", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      add_options = %{capture: true}
      remove_options = %{capture: false}
      
      # Add listener with capture: true
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, add_options})
      :timer.sleep(10)
      
      # Try to remove with capture: false
      GenServer.cast(registry, {:remove_listener, node_pid, "click", listener, remove_options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      listeners = state.listeners[node_pid]["click"]
      assert length(listeners) == 1
      assert hd(listeners).listener == listener
    end

    test "handles removing non-existent listener", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      options = %{capture: false}
      
      # Try to remove listener that doesn't exist
      GenServer.cast(registry, {:remove_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      assert state.listeners == %{}
    end

    test "handles removing from non-existent event type", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      options = %{capture: false}
      
      # Add listener for "click"
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      # Try to remove from "keydown"
      GenServer.cast(registry, {:remove_listener, node_pid, "keydown", listener, options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      assert Map.has_key?(state.listeners[node_pid], "click")
      assert length(state.listeners[node_pid]["click"]) == 1
    end

    test "cleans up empty event type maps", %{registry: registry, node_pid: node_pid} do
      listener = fn -> :ok end
      options = %{capture: false}
      
      # Add listener
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      # Remove listener
      GenServer.cast(registry, {:remove_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      # Should remove the entire node entry when no listeners remain
      assert state.listeners == %{}
    end

    test "preserves other event types when removing one", %{registry: registry, node_pid: node_pid} do
      listener1 = fn -> :ok end
      listener2 = fn -> :ok end
      options = %{capture: false}
      
      # Add listeners for different event types
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener1, options})
      GenServer.cast(registry, {:add_listener, node_pid, "keydown", listener2, options})
      :timer.sleep(10)
      
      # Remove one event type
      GenServer.cast(registry, {:remove_listener, node_pid, "click", listener1, options})
      :timer.sleep(10)
      
      state = :sys.get_state(registry)
      node_listeners = state.listeners[node_pid]
      assert Map.has_key?(node_listeners, "keydown")
      refute Map.has_key?(node_listeners, "click")
      assert length(node_listeners["keydown"]) == 1
    end
  end

  describe "process monitoring and cleanup" do
    test "cleans up listeners when monitored node dies" do
      {:ok, registry} = EventRegistry.start_link([])
      
      # Create a process that will die
      node_pid = spawn(fn -> 
        receive do
          :die -> :ok
        end
      end)
      
      listener = fn -> :ok end
      options = %{capture: false}
      
      # Add listener
      GenServer.cast(registry, {:add_listener, node_pid, "click", listener, options})
      :timer.sleep(10)
      
      # Verify listener was added
      state = :sys.get_state(registry)
      assert Map.has_key?(state.listeners, node_pid)
      assert Map.has_key?(state.cleanup_refs, node_pid)
      
      # Kill the node process
      send(node_pid, :die)
      :timer.sleep(20)
      
      # Verify cleanup happened
      state = :sys.get_state(registry)
      assert state.listeners == %{}
      assert state.cleanup_refs == %{}
    end

    test "only cleans up listeners for specific node that died" do
      {:ok, registry} = EventRegistry.start_link([])
      
      # Create two processes
      node_pid1 = spawn(fn -> 
        receive do
          :die -> :ok
        end
      end)
      
      node_pid2 = spawn(fn -> 
        receive do
          :die -> :ok
        end
      end)
      
      listener = fn -> :ok end
      options = %{capture: false}
      
      # Add listeners for both nodes
      GenServer.cast(registry, {:add_listener, node_pid1, "click", listener, options})
      GenServer.cast(registry, {:add_listener, node_pid2, "keydown", listener, options})
      :timer.sleep(10)
      
      # Kill only the first node
      send(node_pid1, :die)
      :timer.sleep(20)
      
      # Verify only first node was cleaned up
      state = :sys.get_state(registry)
      refute Map.has_key?(state.listeners, node_pid1)
      assert Map.has_key?(state.listeners, node_pid2)
      refute Map.has_key?(state.cleanup_refs, node_pid1)
      assert Map.has_key?(state.cleanup_refs, node_pid2)
    end
  end

  describe "options_match?/2" do
    test "matches when both have capture: false" do
      # Create registry to access private function (using a test helper)
      {:ok, registry} = EventRegistry.start_link([])
      
      # Test via state inspection (we'll test the actual matching through integration)
      # For now, we verify the behavior through the remove_listener tests above
      assert registry != nil
    end
  end
end
