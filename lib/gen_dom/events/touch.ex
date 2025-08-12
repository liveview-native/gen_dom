defmodule GenDOM.TouchEvent do
  @moduledoc """
  Represents a UIEvent sent when the state of contacts with a touch-sensitive surface changes.

  The TouchEvent interface represents a UIEvent sent when the state of contacts with a
  touch-sensitive surface changes. This surface can be a touch screen or trackpad, and the
  events provide detailed information about all touch points, including multi-touch interactions.

  ## Specification Compliance

  This module implements the TouchEvent interface as defined by:
  - **Touch Events Specification**: https://www.w3.org/TR/touch-events/
  - **MDN TouchEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent (extends Event)
      └── GenDOM.TouchEvent (extends UIEvent)
  ```

  **Inherits from:** `GenDOM.UIEvent`

  ## Properties

  ### Keyboard Modifier Properties
  - `alt_key` - Whether the alt key was pressed when the touch event was fired
  - `ctrl_key` - Whether the control key was pressed when the touch event was fired  
  - `meta_key` - Whether the meta key was pressed when the touch event was fired
  - `shift_key` - Whether the shift key was pressed when the touch event was fired

  ### Touch Point Collections
  - `changed_touches` - TouchList of all touch points that changed between this and previous event
  - `target_touches` - TouchList of all touch points currently on the target element
  - `touches` - TouchList of all touch points currently on the touch surface

  ### Non-standard Properties (Experimental)
  - `rotation` - Change in rotation (in degrees) since the event's beginning
  - `scale` - Distance between two digits since the event's beginning

  ## Event Types

  TouchEvent is fired for these touch-related events:
  - `touchstart` - One or more touch points are placed on the touch surface
  - `touchmove` - One or more touch points are moved along the touch surface
  - `touchend` - One or more touch points are removed from the touch surface
  - `touchcancel` - One or more touch points are disrupted (implementation-specific)

  ## Usage

  TouchEvent enables rich touch interactions on mobile devices and touch-enabled computers.
  It supports multi-touch gestures, drag operations, and complex touch-based user interfaces.
  Touch events often fire alongside mouse events for compatibility.

  ## Examples

      # Creating a TouchEvent for touch start
      event = GenDOM.TouchEvent.new("touchstart", %{
        touches: [touch1, touch2],
        target_touches: [touch1],
        changed_touches: [touch1],
        alt_key: false,
        ctrl_key: false,
        meta_key: false,
        shift_key: false,
        view: window,
        detail: 0
      })

      # Accessing touch information
      touches = event.touches
      changed = event.changed_touches
      
      IO.puts("Total touches: \#{length(touches)}")
      IO.puts("Changed touches: \#{length(changed)}")

      # Single finger touch
      single_touch = GenDOM.TouchEvent.new("touchstart", %{
        touches: [touch1],
        target_touches: [touch1],
        changed_touches: [touch1],
        shift_key: false
      })

      # Multi-touch pinch gesture
      pinch_event = GenDOM.TouchEvent.new("touchmove", %{
        touches: [touch1, touch2],
        target_touches: [touch1, touch2],
        changed_touches: [touch1, touch2],
        scale: 1.2,
        rotation: 0
      })

      # Touch end event
      touch_end = GenDOM.TouchEvent.new("touchend", %{
        touches: [],
        target_touches: [],
        changed_touches: [touch1],
        alt_key: false
      })

      # Touch with modifier keys
      modified_touch = GenDOM.TouchEvent.new("touchstart", %{
        touches: [touch1],
        target_touches: [touch1],
        changed_touches: [touch1],
        shift_key: true,
        ctrl_key: false,
        meta_key: false,
        alt_key: false
      })

      # Complex multi-touch interaction
      complex_touch = GenDOM.TouchEvent.new("touchmove", %{
        touches: [touch1, touch2, touch3],
        target_touches: [touch1, touch2],
        changed_touches: [touch2],
        rotation: 15.5,
        scale: 0.8
      })

      # Touch cancel event (system interruption)
      cancel_event = GenDOM.TouchEvent.new("touchcancel", %{
        touches: [],
        target_touches: [],
        changed_touches: [touch1, touch2]
      })
  """

  use GenDOM.UIEvent, [
    # Whether the alt key was pressed when the touch event was fired
    alt_key: false,               # Alt/Option key modifier state
    
    # Whether the control key was pressed when the touch event was fired
    ctrl_key: false,              # Control key modifier state
    
    # Whether the meta key was pressed when the touch event was fired
    meta_key: false,              # Meta/Command key modifier state
    
    # Whether the shift key was pressed when the touch event was fired
    shift_key: false,             # Shift key modifier state
    
    # TouchList of all touch points that changed between this and previous event
    changed_touches: [],          # Touch points that changed in this event
    
    # TouchList of all touch points currently on the target element
    target_touches: [],           # Touch points on the event target
    
    # TouchList of all touch points currently on the touch surface
    touches: [],                  # All active touch points
    
    # Non-standard: Change in rotation (in degrees) since event's beginning
    rotation: 0.0,                # Rotation change in degrees (experimental)
    
    # Non-standard: Distance between two digits since event's beginning
    scale: 1.0                    # Scale factor change (experimental)
  ]
end
