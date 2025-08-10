defmodule GenDOM.MessageEvent do
  @moduledoc """
  Represents a message event in cross-document messaging, WebSockets, and other message-based APIs.

  The MessageEvent interface represents messages received by target objects in various communication
  contexts, including Server-sent events, WebSockets, cross-document messaging, channel messaging,
  Web Workers, broadcast channels, and WebRTC data channels.

  ## Specification Compliance

  This module implements the MessageEvent interface as defined by:
  - **DOM Standard**: https://dom.spec.whatwg.org/#interface-messageevent
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/comms.html#messageevent
  - **MDN MessageEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/MessageEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.MessageEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/message_event.ex`

  ## Properties

  ### Message Data Properties
  - `data` - The data sent by the message emitter (can be any type)
  - `origin` - String representing the origin of the message emitter
  - `last_event_id` - Unique string ID for the event (used in Server-sent events)
  - `source` - Message source (WindowProxy, MessagePort, or ServiceWorker reference)
  - `ports` - Array of MessagePort objects sent with the message

  ## Event Types

  MessageEvent is used for various message-based communications:
  - Cross-document messaging (`postMessage`)
  - Server-sent events (`message`)
  - WebSocket messages (`message`)
  - Web Worker messages (`message`)
  - Broadcast channel messages (`message`)
  - Channel messaging (`message`)
  - WebRTC data channel messages (`message`)

  ## Usage

  MessageEvent is fundamental for asynchronous communication between different contexts
  in web applications, enabling decoupled communication patterns while maintaining
  security through origin validation.

  ## Examples

      # Creating a MessageEvent with data
      {:ok, event} = GenDOM.MessageEvent.new("message", %{
        data: %{type: "user-action", payload: %{action: "save"}},
        origin: "https://example.com",
        last_event_id: "123",
        source: worker_pid
      })

      # Accessing message data
      data = GenDOM.MessageEvent.get(event.pid, :data)
      origin = GenDOM.MessageEvent.get(event.pid, :origin)
      
      # Creating a Server-sent event message
      {:ok, sse_event} = GenDOM.MessageEvent.new("message", %{
        data: "Hello from server",
        origin: "https://server.com",
        last_event_id: "event-456"
      })

      # Creating a WebSocket message event
      {:ok, ws_event} = GenDOM.MessageEvent.new("message", %{
        data: Jason.encode!(%{command: "ping"}),
        origin: "wss://websocket.example.com"
      })

      # Cross-document messaging with ports
      {:ok, cross_doc} = GenDOM.MessageEvent.new("message", %{
        data: "Cross-frame communication",
        origin: "https://parent.com",
        ports: [message_port_1, message_port_2]
      })
  """

  use GenDOM.Event, [
    # The data sent by the message emitter
    data: nil,                    # Any data type sent with the message
    
    # String representing the origin of the message emitter
    origin: "",                   # Origin URL (protocol + domain + port)
    
    # Unique string ID for the event (Server-sent events)
    last_event_id: "",            # Event ID for tracking message sequence
    
    # Message source reference
    source: nil,                  # WindowProxy, MessagePort, or ServiceWorker
    
    # Array of MessagePort objects sent with the message
    ports: []                     # MessagePort objects for channel messaging
  ]

  @doc """
  Initializes the values of a MessageEvent.

  This method implements the MessageEvent `initMessageEvent()` specification. It initializes
  a MessageEvent that was created using the deprecated Document.createEvent() method.

  ## Deprecation Notice
  **This method is deprecated.** Use the MessageEvent() constructor instead to create
  and initialize message events. This method is maintained only for backward compatibility
  with legacy code.

  ## Parameters
  - `event_pid` - The PID of the MessageEvent object to initialize
  - `type` - A string defining the type of event (typically "message")
  - `can_bubble` - A boolean indicating whether the event can bubble up through the DOM
  - `cancelable` - A boolean indicating whether the event's default action can be prevented
  - `data` - The message data to be sent
  - `origin` - A string representing the origin of the message emitter
  - `last_event_id` - A string with the unique ID of the event
  - `source` - The message event source (WindowProxy, MessagePort, or ServiceWorker)
  - `ports` - An array of MessagePort objects representing the message channels

  ## Returns
  Returns `:not_implemented` (would normally return undefined/nil)

  ## Examples
      # Legacy code example (deprecated - do not use in new code)
      event = Document.create_event(document.pid, "MessageEvent")
      GenDOM.MessageEvent.init_message_event(event.pid,
        "message",                    # type
        false,                        # can_bubble
        false,                        # cancelable
        %{action: "save"},           # data
        "https://example.com",       # origin
        "event-123",                 # last_event_id
        worker.pid,                  # source
        [port1, port2]               # ports
      )

  ## Modern Alternative
  Instead of using this deprecated method, create MessageEvent instances directly:

      {:ok, event} = MessageEvent.new("message", %{
        bubbles: false,
        cancelable: false,
        data: %{action: "save"},
        origin: "https://example.com",
        last_event_id: "event-123",
        source: worker,
        ports: [port1, port2]
      })

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/MessageEvent/initMessageEvent
  """
  def init_message_event(_event_pid, _type, _can_bubble, _cancelable, _data, _origin, _last_event_id, _source, _ports) do
    :not_implemented
  end
end