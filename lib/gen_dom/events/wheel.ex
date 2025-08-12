defmodule GenDOM.WheelEvent do
  @moduledoc """
  Represents events that occur due to user interaction with a mouse wheel or similar device.

  The WheelEvent interface represents events that occur due to the user moving a mouse wheel
  or similar input device. This includes traditional mouse wheels, trackpad gestures, and
  other scrolling mechanisms.

  ## Specification Compliance

  This module implements the WheelEvent interface as defined by:
  - **UI Events Specification**: https://www.w3.org/TR/uievents/#interface-wheelevent
  - **MDN WheelEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent
      └── GenDOM.MouseEvent
          └── GenDOM.WheelEvent (extends MouseEvent)
  ```

  **Inherits from:** `GenDOM.MouseEvent`

  ## Properties

  ### Scroll Deltas
  - `delta_x` - Horizontal scroll amount
  - `delta_y` - Vertical scroll amount (positive = down/right, negative = up/left)
  - `delta_z` - Scroll amount for the z-axis
  - `delta_mode` - Unit of measurement for delta values

  ### Deprecated Properties
  - `wheel_delta` - Legacy vertical scroll amount (deprecated, use delta_y)
  - `wheel_delta_x` - Legacy horizontal scroll amount (deprecated, use delta_x)
  - `wheel_delta_y` - Legacy vertical scroll amount (deprecated, use delta_y)

  ## Delta Modes

  The `delta_mode` property indicates the unit of measurement:
  - `0` (DOM_DELTA_PIXEL) - Delta values are in pixels
  - `1` (DOM_DELTA_LINE) - Delta values are in lines
  - `2` (DOM_DELTA_PAGE) - Delta values are in pages

  ## Event Types

  WheelEvent is used for:
  - `wheel` - The wheel has been rotated

  Note: The legacy `mousewheel` and `DOMMouseScroll` events are deprecated.

  ## Platform Differences

  Different platforms and input devices may report scroll amounts differently:
  - Mouse wheels typically scroll by lines
  - Trackpads often scroll by pixels
  - The delta values and modes may vary between browsers and operating systems

  ## Examples

      # Creating a WheelEvent
      event = GenDOM.WheelEvent.new("wheel", %{
        delta_x: 0,
        delta_y: 100,
        delta_z: 0,
        delta_mode: 0,  # DOM_DELTA_PIXEL
        bubbles: true,
        cancelable: true
      })

      # Handling wheel events
      case event.delta_mode do
        0 -> # DOM_DELTA_PIXEL
          scroll_by_pixels(event.delta_y)
        1 -> # DOM_DELTA_LINE
          scroll_by_lines(event.delta_y)
        2 -> # DOM_DELTA_PAGE
          scroll_by_pages(event.delta_y)
      end

      # Detecting scroll direction
      cond do
        event.delta_y > 0 -> IO.puts("Scrolling down")
        event.delta_y < 0 -> IO.puts("Scrolling up")
        event.delta_x > 0 -> IO.puts("Scrolling right")
        event.delta_x < 0 -> IO.puts("Scrolling left")
      end
  """

  use GenDOM.MouseEvent, [
    # Scroll delta values
    delta_x: 0.0,                 # Horizontal scroll amount
    delta_y: 0.0,                 # Vertical scroll amount
    delta_z: 0.0,                 # Z-axis scroll amount (rarely used)
    delta_mode: 0,                # Unit of delta values (0=pixels, 1=lines, 2=pages)
    
    # Deprecated properties (maintained for compatibility)
    wheel_delta: 0,               # Legacy vertical scroll (deprecated, use delta_y)
    wheel_delta_x: 0,             # Legacy horizontal scroll (deprecated, use delta_x)
    wheel_delta_y: 0              # Legacy vertical scroll (deprecated, use delta_y)
  ]

  # Delta mode constants
  @dom_delta_pixel 0
  @dom_delta_line 1
  @dom_delta_page 2

  @doc """
  Returns the DOM_DELTA_PIXEL constant value (0).

  Indicates delta values are specified in pixels.
  """
  def dom_delta_pixel, do: @dom_delta_pixel

  @doc """
  Returns the DOM_DELTA_LINE constant value (1).

  Indicates delta values are specified in lines.
  """
  def dom_delta_line, do: @dom_delta_line

  @doc """
  Returns the DOM_DELTA_PAGE constant value (2).

  Indicates delta values are specified in pages.
  """
  def dom_delta_page, do: @dom_delta_page
end
