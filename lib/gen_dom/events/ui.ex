defmodule GenDOM.UIEvent do
  @moduledoc """
  Represents simple user interface events.

  The UIEvent interface represents simple user interface events. UIEvent derives from Event.
  Although the UIEvent.initUIEvent() method is kept for backward compatibility, you should
  create a UIEvent object using the UIEvent() constructor.

  Several interfaces extend UIEvent, including MouseEvent, TouchEvent, FocusEvent, KeyboardEvent,
  WheelEvent, InputEvent, and CompositionEvent.

  ## Specification Compliance

  This module implements the UIEvent interface as defined by:
  - **UI Events Specification**: https://www.w3.org/TR/uievents/
  - **DOM Level 3 Events**: https://www.w3.org/TR/DOM-Level-3-Events/#events-uievents
  - **MDN UIEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/UIEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent (extends Event)
      ├── GenDOM.MouseEvent (extends UIEvent)
      ├── GenDOM.KeyboardEvent (extends UIEvent)
      ├── GenDOM.TouchEvent (extends UIEvent)
      ├── GenDOM.FocusEvent (extends UIEvent)
      ├── GenDOM.WheelEvent (extends UIEvent)
      └── GenDOM.CompositionEvent (extends UIEvent)
  ```

  **Inherits from:** `GenDOM.Event`

  ## Properties

  ### Event Context Properties
  - `view` - WindowProxy that generated the event (typically the window object)
  - `detail` - Event-specific value providing additional information

  ### Legacy Properties
  - `which` - Numeric keyCode or button number (deprecated, use KeyboardEvent.key or MouseEvent.button)
  - `source_capabilities` - InputDeviceCapabilities of the physical device (experimental)

  ## Event Types

  UIEvent is used for the following event types:
  - `load` - Resource has loaded
  - `unload` - Document or resource is being unloaded
  - `abort` - Loading of resource has been aborted
  - `error` - Error occurred while loading resource
  - `select` - Text has been selected
  - `resize` - Document view has been resized
  - `scroll` - Document view or element has been scrolled

  ## Usage

  UIEvent serves primarily as a base class for more specific UI event types.
  Most applications will use the derived event types (MouseEvent, KeyboardEvent, etc.)
  rather than UIEvent directly.

  ## Examples

      # Creating a UIEvent (typically you'd use a more specific event type)
      {:ok, event} = GenDOM.UIEvent.new("resize", %{
        view: window,
        detail: 0
      })

      # Accessing UIEvent properties
      view = event.view
      detail = event.detail
  """

  use GenDOM.Event, [
    # The Window object from which the event was generated
    detail: nil,                  # Event-specific value with semantic information
    
    # Experimental property for input device capabilities
    source_capabilities: nil,     # InputDeviceCapabilities of physical device (experimental)
    
    # The WindowProxy that generated the event
    view: nil,                    # Usually the Window object
    
    # Legacy property for keyboard/mouse button identification
    which: nil                    # Deprecated: numeric keyCode or button number
  ]

  @doc """
  Initializes the value of a UIEvent created using Document.createEvent().

  This method implements the UIEvent `initUIEvent()` specification. It initializes
  a UIEvent that was created using the deprecated Document.createEvent() method.

  ## Deprecation Notice
  **This method is deprecated.** Use the UIEvent() constructor instead to create
  and initialize UI events. This method is maintained only for backward compatibility
  with legacy code.

  ## Parameters
  - `event` - The UIEvent struct to initialize
  - `type` - A string defining the type of event (e.g., "load", "resize", "scroll")
  - `can_bubble` - A boolean indicating whether the event can bubble up through the DOM
  - `cancelable` - A boolean indicating whether the event's default action can be prevented
  - `view` - The Window object associated with the event (typically window)
  - `detail` - An event-dependent value providing additional information (defaults to 0)

  ## Returns
  Returns `:not_implemented` (would normally return undefined/nil)

  ## Examples
      # Legacy code example (deprecated - do not use in new code)
      event = Document.create_event(document, "UIEvent")
      GenDOM.UIEvent.init_ui_event(event,
        "resize",          # type
        false,             # can_bubble (resize doesn't bubble)
        false,             # cancelable (resize can't be cancelled)
        window,            # view
        0                  # detail
      )

  ## Modern Alternative
  Instead of using this deprecated method, create UIEvent instances directly:

      event = UIEvent.new("resize", %{
        bubbles: false,
        cancelable: false,
        view: window,
        detail: 0
      })

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/UIEvent/initUIEvent
  """
  def init_ui_event(_event, _type, _can_bubble, _cancelable, _view, _detail) do
    :not_implemented
  end
end
