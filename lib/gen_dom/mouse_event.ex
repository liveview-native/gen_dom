defmodule GenDOM.MouseEvent do
  @moduledoc """
  Represents events that occur due to user interaction with a pointing device.

  The MouseEvent interface represents events that occur due to the user interacting with
  a pointing device (such as a mouse). Common events using this interface include click,
  dblclick, mouseup, and mousedown.

  MouseEvent derives from UIEvent, which in turn derives from Event. Though the
  MouseEvent.initMouseEvent() method is kept for backward compatibility, you should
  create a MouseEvent object using the MouseEvent() constructor.

  ## Specification Compliance

  This module implements the MouseEvent interface as defined by:
  - **UI Events Specification**: https://www.w3.org/TR/uievents/#mouseevent
  - **CSSOM View Module**: https://www.w3.org/TR/cssom-view-1/
  - **MDN MouseEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent
      └── GenDOM.MouseEvent (extends UIEvent)
          ├── GenDOM.PointerEvent (extends MouseEvent)
          ├── GenDOM.WheelEvent (extends MouseEvent)
          └── GenDOM.DragEvent (extends MouseEvent)
  ```

  **Inherits from:** `GenDOM.UIEvent`
  **File:** `lib/gen_dom/mouse_event.ex`

  ## Properties

  ### Modifier Keys
  - `alt_key` - True if Alt key was pressed
  - `ctrl_key` - True if Control key was pressed
  - `meta_key` - True if Meta key (Command/Windows) was pressed
  - `shift_key` - True if Shift key was pressed

  ### Button Information
  - `button` - Button number that was pressed (0=main, 1=auxiliary, 2=secondary)
  - `buttons` - Bitmask of buttons currently pressed

  ### Coordinates
  - `client_x` / `client_y` - Position relative to viewport
  - `screen_x` / `screen_y` - Position relative to screen
  - `page_x` / `page_y` - Position relative to document
  - `offset_x` / `offset_y` - Position relative to target element's padding edge
  - `movement_x` / `movement_y` - Movement since last mousemove event
  - `x` / `y` - Aliases for client_x / client_y

  ### Event Targeting
  - `related_target` - Secondary target for the event (e.g., element being entered on mouseout)

  ### Non-standard Properties
  - `layer_x` / `layer_y` - Position relative to current layer (non-standard)
  - `moz_input_source` - Type of device that generated event (Mozilla-specific)
  - `webkit_force` - Pressure applied when clicking (WebKit-specific)

  ## Event Types

  MouseEvent is used for the following event types:
  - `click` - Button pressed and released on an element
  - `dblclick` - Button clicked twice on an element
  - `mousedown` - Button pressed on an element
  - `mouseup` - Button released over an element
  - `mouseenter` - Pointer enters element bounds (doesn't bubble)
  - `mouseleave` - Pointer leaves element bounds (doesn't bubble)
  - `mousemove` - Pointer moves within element
  - `mouseout` - Pointer leaves element or enters child
  - `mouseover` - Pointer enters element or leaves child
  - `contextmenu` - Context menu should be displayed

  ## Examples

      # Creating a MouseEvent
      {:ok, event} = GenDOM.MouseEvent.new("click", %{
        bubbles: true,
        cancelable: true,
        view: window,
        client_x: 100,
        client_y: 200,
        ctrl_key: false,
        alt_key: false,
        shift_key: false,
        meta_key: false,
        button: 0
      })

      # Checking modifier keys
      is_ctrl = GenDOM.MouseEvent.get_modifier_state(event.pid, "Control")
      
      # Getting coordinates
      x = GenDOM.MouseEvent.get(event.pid, :client_x)
      y = GenDOM.MouseEvent.get(event.pid, :client_y)
  """

  use GenDOM.UIEvent, [
    # Modifier keys - indicate which modifier keys were pressed
    alt_key: false,                # True if Alt/Option key was down when event fired
    ctrl_key: false,               # True if Control key was down when event fired
    meta_key: false,               # True if Meta key (Command on Mac, Windows key on PC) was down
    shift_key: false,              # True if Shift key was down when event fired
    
    # Button states - identify which mouse buttons are involved
    button: 0,                     # Button number pressed/released (0=main/left, 1=auxiliary/middle, 2=secondary/right)
    buttons: 0,                    # Bitmask of buttons currently pressed (1=main, 2=secondary, 4=auxiliary)
    
    # Viewport coordinates - position relative to the browser viewport
    client_x: 0,                   # X coordinate relative to viewport (excludes scroll offset)
    client_y: 0,                   # Y coordinate relative to viewport (excludes scroll offset)
    
    # Movement deltas - used for pointer lock API
    movement_x: 0,                 # X movement since last mousemove event
    movement_y: 0,                 # Y movement since last mousemove event
    
    # Element-relative coordinates - position within the target element
    offset_x: 0,                   # X coordinate relative to padding edge of target element
    offset_y: 0,                   # Y coordinate relative to padding edge of target element
    
    # Document coordinates - position relative to the entire document
    page_x: 0,                     # X coordinate relative to whole document (includes scroll)
    page_y: 0,                     # Y coordinate relative to whole document (includes scroll)
    
    # Screen coordinates - position relative to the user's screen
    screen_x: 0,                   # X coordinate relative to screen/monitor
    screen_y: 0,                   # Y coordinate relative to screen/monitor
    
    # Event targeting - identifies related elements
    related_target: nil,           # Secondary target (element exited on enter, entered on exit)
    
    # Coordinate aliases - shorthand properties
    x: 0,                          # Alias for client_x (viewport X coordinate)
    y: 0,                          # Alias for client_y (viewport Y coordinate)
    
    # Non-standard properties - browser-specific extensions
    layer_x: 0,                    # X coordinate relative to current layer (non-standard, deprecated)
    layer_y: 0,                    # Y coordinate relative to current layer (non-standard, deprecated)
    moz_input_source: 0,           # Input device type: 1=mouse, 2=pen, 3=eraser, 4=cursor, 5=keyboard, 6=touch (Mozilla)
    webkit_force: 0.0              # Force/pressure of click on Force Touch trackpad (WebKit/Safari)
  ]

  @doc """
  Returns the current state of the specified modifier key.

  This method implements the MouseEvent `getModifierState()` specification. It returns
  whether a modifier key (such as Alt, Control, Meta, or Shift) was pressed when the
  mouse event was fired.

  ## Parameters
  - `event_pid` - The PID of the MouseEvent object
  - `key` - A case-sensitive string representing the modifier key to query. Valid values include:
    - "Alt" - The Alt key (Option on macOS)
    - "Control" - The Control key
    - "Meta" - The Meta key (Command on macOS, Windows key on Windows)
    - "Shift" - The Shift key
    - "AltGraph" - The AltGraph key
    - "CapsLock" - The Caps Lock key
    - "NumLock" - The Num Lock key
    - "ScrollLock" - The Scroll Lock key
    - "Accel" - Virtual modifier (deprecated) mapped to Control on Windows/Linux, Command on macOS

  ## Returns
  - `true` if the specified modifier key is active (pressed or locked)
  - `false` if the modifier key is not active

  ## Examples
      # Check if Control key was pressed during the mouse event
      is_ctrl_pressed = GenDOM.MouseEvent.get_modifier_state(event.pid, "Control")
      
      # Check if Meta (Command/Windows) key was pressed
      is_meta_pressed = GenDOM.MouseEvent.get_modifier_state(event.pid, "Meta")
      
      # Check multiple modifiers
      if GenDOM.MouseEvent.get_modifier_state(event.pid, "Shift") and
         GenDOM.MouseEvent.get_modifier_state(event.pid, "Alt") do
        # Handle Shift+Alt combination
      end

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/getModifierState
  """
  def get_modifier_state(_event_pid, _key) do
    :not_implemented
  end

  @doc """
  Initializes the value of a MouseEvent created using Document.createEvent().

  This method implements the MouseEvent `initMouseEvent()` specification. It initializes
  a mouse event that was created using the deprecated Document.createEvent() method.
  
  ## Deprecation Notice
  **This method is deprecated.** Use the MouseEvent() constructor instead to create
  and initialize mouse events. This method is maintained only for backward compatibility
  with legacy code.

  ## Parameters
  - `event_pid` - The PID of the MouseEvent object to initialize
  - `type` - A string defining the type of event (e.g., "click", "mousedown", "mouseup", "mouseover")
  - `can_bubble` - A boolean indicating whether the event can bubble up through the DOM
  - `cancelable` - A boolean indicating whether the event's default action can be prevented
  - `view` - The Window object associated with the event (typically window)
  - `detail` - A number indicating the mouse click count (1 for single-click, 2 for double-click, etc.)
  - `screen_x` - The horizontal position of the mouse in screen coordinates
  - `screen_y` - The vertical position of the mouse in screen coordinates
  - `client_x` - The horizontal position of the mouse in client/viewport coordinates
  - `client_y` - The vertical position of the mouse in client/viewport coordinates
  - `ctrl_key` - A boolean indicating whether the Control key was pressed
  - `alt_key` - A boolean indicating whether the Alt key was pressed
  - `shift_key` - A boolean indicating whether the Shift key was pressed
  - `meta_key` - A boolean indicating whether the Meta key was pressed
  - `button` - A number indicating which mouse button was pressed (0=left, 1=middle, 2=right)
  - `related_target` - The secondary target for the event (used for mouseover/mouseout events)

  ## Returns
  Returns `:not_implemented` (would normally return undefined/nil)

  ## Examples
      # Legacy code example (deprecated - do not use in new code)
      event = Document.create_event(document.pid, "MouseEvent")
      GenDOM.MouseEvent.init_mouse_event(event.pid,
        "click",           # type
        true,              # can_bubble
        true,              # cancelable
        window.pid,        # view
        1,                 # detail (click count)
        100,               # screen_x
        200,               # screen_y
        50,                # client_x
        75,                # client_y
        false,             # ctrl_key
        false,             # alt_key
        false,             # shift_key
        false,             # meta_key
        0,                 # button (left)
        nil                # related_target
      )

  ## Modern Alternative
  Instead of using this deprecated method, create MouseEvent instances directly:
  
      event = MouseEvent.new("click", %{
        bubbles: true,
        cancelable: true,
        view: window,
        detail: 1,
        screen_x: 100,
        screen_y: 200,
        client_x: 50,
        client_y: 75,
        ctrl_key: false,
        alt_key: false,
        shift_key: false,
        meta_key: false,
        button: 0,
        related_target: nil
      })

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/initMouseEvent
  """
  def init_mouse_event(
    _event_pid,
    _type,
    _can_bubble,
    _cancelable,
    _view,
    _detail,
    _screen_x,
    _screen_y,
    _client_x,
    _client_y,
    _ctrl_key,
    _alt_key,
    _shift_key,
    _meta_key,
    _button,
    _related_target
  ) do
    :not_implemented
  end
end
