defmodule GenDOM.EventTarget do
  @moduledoc """
  EventTarget interface implementation for GenDOM.

  The EventTarget interface is implemented by objects that can receive events and may have
  listeners for them. EventTarget is a DOM interface implemented by objects that can receive
  events and may have listeners for them.

  This module provides an Elixir implementation of the Web API EventTarget interface,
  allowing objects to receive events and register/remove event listeners.

  ## Usage

  To use EventTarget functionality in your module:

      defmodule MyModule do
        use GenDOM.EventTarget

        # Now you can use add_event_listener/3, remove_event_listener/3, dispatch_event/2
      end
  """

  use GenObject, []

  @doc """
  Registers an event handler of a specific event type on the EventTarget.

  ## Parameters

  - `node` - The EventTarget to register the listener on
  - `type` - A string representing the event type to listen for
  - `listener` - The event handler function or module
  - `options` - A list of options that specify characteristics about the event listener

  ## Options

  - `:capture` - Boolean indicating if events should be captured during the capture phase
  - `:once` - Boolean indicating if the listener should be invoked only once
  - `:passive` - Boolean indicating if the listener will never call preventDefault()
  - `:signal` - An AbortSignal to remove the event listener

  ## Examples

      iex> GenDOM.EventTarget.add_event_listener(node, "click", fn event -> IO.puts("Clicked!") end)
      :ok

  """
  def add_event_listener(node, type, listener, opts \\ [])
  def add_event_listener(_node, _type, listener, opts) when is_list(opts) and is_function(listener) do
    :not_implemented
  end

  def add_event_listener(_node, _type, listener, use_capture?) when is_boolean(use_capture?) and is_function(listener) do
    :not_implemented
  end

  defoverridable add_event_listener: 3

  @doc """
  Dispatches an event to this EventTarget.

  Dispatches an event at the specified EventTarget, invoking the affected event listeners
  in the appropriate order.

  ## Parameters

  - `node` - The EventTarget to dispatch the event on
  - `event` - The event to dispatch

  ## Returns

  Returns `false` if the event is cancelable and at least one of the event handlers
  which received the event called `preventDefault()`. Otherwise, returns `true`.

  ## Examples

      iex> event = GenDOM.Event.new("click")
      iex> GenDOM.EventTarget.dispatch_event(node, event)
      true

  """
  def dispatch_event(_node, _event) do
    nil
  end

  defoverridable dispatch_event: 2

  @doc """
  Removes an event listener with additional options.

  ## Parameters

  - `node` - The EventTarget to remove the listener from
  - `type` - A string representing the event type to remove
  - `listener` - The event handler function or module to remove

  ## Options

  - `options` - A list of options that specify characteristics about the event listener
  - `:capture` - Boolean indicating if the listener was registered for the capture phase

  ## Examples

      iex> GenDOM.EventTarget.remove_event_listener(node, "click", listener, [capture: true])
      :ok

  """
  def remove_event_listener(node, type, listener, opts \\ [])
  def remove_event_listener(_node, _type, _listener, opts) when is_list(opts) do
    nil
  end

  def remove_event_listener(_node, _type, _listener, use_capture?) when is_boolean(use_capture?) do
    nil
  end

  defoverridable remove_event_listener: 4
end
