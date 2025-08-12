defmodule GenDOM.DragEvent do
  @moduledoc """
  Represents events related to drag and drop operations.

  The DragEvent interface is a DOM event that represents a drag and drop interaction.
  The user initiates a drag by placing a pointer device (such as a mouse) on the touch
  surface and then dragging the pointer to a new location (such as another DOM element).

  ## Specification Compliance

  This module implements the DragEvent interface as defined by:
  - **HTML Drag and Drop API**: https://html.spec.whatwg.org/multipage/dnd.html#dragevent
  - **MDN DragEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/DragEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent
      └── GenDOM.MouseEvent
          └── GenDOM.DragEvent (extends MouseEvent)
  ```

  **Inherits from:** `GenDOM.MouseEvent`

  ## Properties

  ### Data Transfer
  - `data_transfer` - The DataTransfer object containing data being dragged and drop effect information

  ## Event Types

  DragEvent is used for the following event types:
  - `dragstart` - User starts dragging an element or text selection
  - `drag` - Element is being dragged (fires continuously)
  - `dragenter` - Dragged element enters a valid drop target
  - `dragover` - Element is dragged over a valid drop target (fires continuously)
  - `dragleave` - Dragged element leaves a valid drop target
  - `drop` - Element is dropped on a valid drop target
  - `dragend` - Drag operation is complete (fires on source element)

  ## Event Flow

  A typical drag and drop sequence:
  1. `dragstart` on the source element
  2. `drag` events while dragging
  3. `dragenter` when entering a drop target
  4. `dragover` while over a drop target
  5. `dragleave` if leaving the target or `drop` if released
  6. `dragend` on the source element

  ## DataTransfer Object

  The `data_transfer` property provides:
  - Data being transferred (files, text, URLs, etc.)
  - Allowed effects (copy, move, link)
  - Visual feedback customization
  - Drop effect determination

  ## Examples

      # Creating a DragEvent
      event = GenDOM.DragEvent.new("dragstart", %{
        data_transfer: data_transfer_object,
        bubbles: true,
        cancelable: true,
        view: window,
        client_x: 100,
        client_y: 200
      })

      # Handling drag and drop
      case event.type do
        "dragstart" ->
          # Set data to be transferred
          DataTransfer.set_data(event.data_transfer, "text/plain", element_id)
          DataTransfer.set_effect_allowed(event.data_transfer, "move")
          
        "dragover" ->
          # Must prevent default to allow drop
          Event.prevent_default(event)
          DataTransfer.set_drop_effect(event.data_transfer, "move")
          
        "drop" ->
          Event.prevent_default(event)
          data = DataTransfer.get_data(event.data_transfer, "text/plain")
          handle_drop(data, event.target)
          
        "dragend" ->
          # Clean up after drag operation
          cleanup_drag_state()
      end
  """

  use GenDOM.MouseEvent, [
    # The data being transferred during the drag and drop operation
    data_transfer: nil            # DataTransfer object with drag data and metadata
  ]
end
