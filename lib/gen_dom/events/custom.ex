defmodule GenDOM.CustomEvent do
  @moduledoc """
  Represents events initialized by an application for any purpose.

  The CustomEvent interface represents events initialized by an application for any purpose.
  This interface allows developers to create custom events with arbitrary data attached,
  enabling communication between different parts of an application through the DOM event system.

  ## Specification Compliance

  This module implements the CustomEvent interface as defined by:
  - **DOM Standard**: https://dom.spec.whatwg.org/#interface-customevent
  - **MDN CustomEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.CustomEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`

  ## Properties

  ### Custom Data
  - `detail` - Any data passed when initializing the event (can be any type)

  ## Event Types

  CustomEvent can be used for any custom event type defined by the application.
  Common patterns include:
  - Component lifecycle events
  - Inter-component communication
  - Application state changes
  - Custom user interactions
  - Plugin or extension events

  ## Usage

  CustomEvent is particularly useful when you need to pass custom data along with an event,
  allowing for rich communication between different parts of your application without
  tight coupling.

  ## Examples

      # Creating a CustomEvent with data
      event = GenDOM.CustomEvent.new("user-login", %{
        detail: %{
          user_id: 123,
          username: "john_doe",
          timestamp: DateTime.utc_now()
        },
        bubbles: true,
        cancelable: true
      })

      # Accessing custom data
      user_data = event.detail
      IO.puts("User \#{user_data.username} logged in")

      # Creating a simple notification event
      notification = GenDOM.CustomEvent.new("notification", %{
        detail: "File saved successfully",
        bubbles: true
      })
  """

  use GenDOM.Event, [
    # Custom data attached to the event
    detail: nil                   # Any application-specific data
  ]

  @doc """
  Initializes a CustomEvent object.

  This method implements the CustomEvent `initCustomEvent()` specification. It initializes
  a CustomEvent that was created using the deprecated Document.createEvent() method.

  ## Deprecation Notice
  **This method is deprecated.** Use the CustomEvent() constructor instead to create
  and initialize custom events. This method is maintained only for backward compatibility.

  ## Parameters
  - `event` - The CustomEvent struct to initialize
  - `type` - A string defining the type of event
  - `can_bubble` - A boolean indicating whether the event can bubble up through the DOM
  - `cancelable` - A boolean indicating whether the event's default action can be prevented
  - `detail` - Any custom data to attach to the event

  ## Returns
  Returns `:not_implemented` (would normally return undefined/nil)

  ## Examples
      # Legacy code example (deprecated - do not use in new code)
      event = Document.create_event(document, "CustomEvent")
      GenDOM.CustomEvent.init_custom_event(event,
        "user-action",     # type
        true,              # can_bubble
        true,              # cancelable
        %{action: "save"}  # detail
      )

  ## Modern Alternative
  Instead of using this deprecated method, create CustomEvent instances directly:

      event = GenDOM.CustomEvent.new("user-action", %{
        bubbles: true,
        cancelable: true,
        detail: %{action: "save"}
      })

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent/initCustomEvent
  """
  def init_custom_event(_event, _type, _can_bubble, _cancelable, _detail) do
    :not_implemented
  end
end
