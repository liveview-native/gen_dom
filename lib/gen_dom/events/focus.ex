defmodule GenDOM.FocusEvent do
  @moduledoc """
  Represents events related to focus changes.

  The FocusEvent interface represents focus-related events, including focus, blur, focusin,
  and focusout. These events track when elements gain or lose focus, which is essential for
  form validation, accessibility features, and user interface interactions.

  ## Specification Compliance

  This module implements the FocusEvent interface as defined by:
  - **UI Events Specification**: https://www.w3.org/TR/uievents/#interface-focusevent
  - **MDN FocusEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent
      └── GenDOM.FocusEvent (extends UIEvent)
  ```

  **Inherits from:** `GenDOM.UIEvent`

  ## Properties

  ### Focus Target Information
  - `related_target` - The secondary target for the event (element losing/gaining focus)

  ## Event Types

  FocusEvent is used for the following event types:
  - `focus` - Element has received focus (doesn't bubble)
  - `blur` - Element has lost focus (doesn't bubble)
  - `focusin` - Element is about to receive focus (bubbles)
  - `focusout` - Element is about to lose focus (bubbles)

  ## Event Order

  When focus shifts between elements, events fire in this order:
  1. `blur` - On the element losing focus
  2. `focusout` - On the element losing focus (bubbling)
  3. `focus` - On the element gaining focus
  4. `focusin` - On the element gaining focus (bubbling)

  ## Related Target Behavior

  The `related_target` property indicates:
  - For `focus`/`focusin`: The element losing focus
  - For `blur`/`focusout`: The element gaining focus
  - May be `null` for security reasons (cross-origin) or when focus moves to/from non-DOM entities

  ## Examples

      # Creating a FocusEvent
      event = GenDOM.FocusEvent.new("focus", %{
        bubbles: false,
        cancelable: false,
        view: window,
        related_target: previous_element
      })

      # Handling focus events
      case event.type do
        "focus" ->
          # Element gained focus
          highlight_element(event.target)
        "blur" ->
          # Element lost focus
          validate_field(event.target)
        "focusin" ->
          # Element or child is gaining focus (bubbles)
          show_help_text(event.target)
        "focusout" ->
          # Element or child is losing focus (bubbles)
          hide_help_text(event.target)
      end

      # Tracking focus movement
      if event.related_target do
        IO.puts("Focus moved from \#{event.related_target} to \#{event.target}")
      end
  """

  use GenDOM.UIEvent, [
    # The element losing focus (on focus/focusin) or gaining focus (on blur/focusout)
    related_target: nil           # Secondary target for the focus event
  ]
end
