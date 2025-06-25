defmodule GenDOM.EventTarget do
  defmacro __using__(_opts) do
    quote do
      defdelegate add_event_listener(node, type, listener), to: GenDOM.EventTarget
      defdelegate add_event_listener(node, type, options), to: GenDOM.EventTarget
      defdelegate add_event_listener(node, type, use_capture?), to: GenDOM.EventTarget
      defdelegate dispatch_event(node, event), to: GenDOM.EventTarget
      defdelegate remove_event_listener(node, type, listener), to: GenDOM.EventTarget
      defdelegate remove_event_listener(node, type, options), to: GenDOM.EventTarget
      defdelegate remove_event_listener(node, type, use_capture?), to: GenDOM.EventTarget
    end
  end

  def add_event_listener(node, type, listener) do

  end

  def add_event_listener(node, type, listener, options \\ []) when is_list(options) do

  end

  def add_event_listener(node, type, listener, use_capture?) when is_boolean(use_capture?) do

  end

  def dispatch_event(node, event) do
    
  end

  def remove_event_listener(node, type, listener) do

  end

  def remove_event_listener(node, type, listener, options \\ []) when is_list(options) do

  end

  def remove_event_listener(node, type, listener, use_capture?) when is_boolean(use_capture?) do

  end
end
