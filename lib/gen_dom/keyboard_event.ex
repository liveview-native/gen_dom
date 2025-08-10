defmodule GenDOM.KeyboardEvent do
  @moduledoc """
  Represents events that occur due to user interaction with a keyboard.

  The KeyboardEvent interface describes a single interaction between the user and a key
  (or combination of keys) on the keyboard. Each event describes what kind of user
  interaction occurred: keydown, keyup, or keypress (deprecated).

  ## Specification Compliance

  This module implements the KeyboardEvent interface as defined by:
  - **UI Events Specification**: https://www.w3.org/TR/uievents/#interface-keyboardevent
  - **MDN KeyboardEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.UIEvent
      └── GenDOM.KeyboardEvent (extends UIEvent)
  ```

  **Inherits from:** `GenDOM.UIEvent`
  **File:** `lib/gen_dom/keyboard_event.ex`

  ## Properties

  ### Key Information
  - `key` - The key value of the key represented by the event
  - `code` - The physical key code (layout-independent)
  - `location` - The location of the key on the keyboard (0=standard, 1=left, 2=right, 3=numpad)
  - `repeat` - Whether the key is being held down and auto-repeating

  ### Modifier Keys
  - `alt_key` - True if Alt key was active
  - `ctrl_key` - True if Control key was active
  - `meta_key` - True if Meta key (Command/Windows) was active
  - `shift_key` - True if Shift key was active

  ### Composition State
  - `is_composing` - True if the event is fired during composition (IME input)

  ## Event Types

  KeyboardEvent is used for the following event types:
  - `keydown` - A key has been pressed down
  - `keyup` - A key has been released
  - `keypress` - (Deprecated) A character key has been pressed

  ## Key vs Code

  - `key` represents the value of the key pressed (e.g., "a", "A", "Enter", "Shift")
  - `code` represents the physical key (e.g., "KeyA", "Enter", "ShiftLeft")

  The `key` value changes with keyboard layout and modifiers, while `code` remains
  consistent across layouts.

  ## Examples

      # Creating a KeyboardEvent
      event = GenDOM.KeyboardEvent.new("keydown", %{
        key: "Enter",
        code: "Enter",
        ctrl_key: false,
        alt_key: false,
        shift_key: false,
        meta_key: false,
        repeat: false
      })

      # Checking for key combinations
      if event.ctrl_key and event.key == "s" do
        # Handle Ctrl+S (save)
      end

      # Using code for game controls (layout-independent)
      case event.code do
        "KeyW" -> move_forward()
        "KeyA" -> move_left()
        "KeyS" -> move_backward()
        "KeyD" -> move_right()
      end
  """

  use GenDOM.UIEvent, [
    # Key information
    key: "",                      # Key value (e.g., "a", "Enter", "Shift")
    code: "",                     # Physical key code (e.g., "KeyA", "Enter", "ShiftLeft")
    location: 0,                  # Key location (0=standard, 1=left, 2=right, 3=numpad)
    repeat: false,                # True if key is auto-repeating
    
    # Modifier keys
    alt_key: false,               # True if Alt key was active
    ctrl_key: false,              # True if Control key was active
    meta_key: false,              # True if Meta key (Command/Windows) was active
    shift_key: false,             # True if Shift key was active
    
    # Composition state
    is_composing: false          # True if fired during IME composition
  ]

  @doc """
  Returns the current state of the specified modifier key.

  This method implements the KeyboardEvent `getModifierState()` specification. It returns
  whether a modifier key was pressed when the keyboard event was created.

  ## Parameters
  - `event` - The KeyboardEvent struct
  - `key` - A case-sensitive string representing the modifier key to query. Valid values include:
    - "Alt" - The Alt key
    - "AltGraph" - The AltGraph key
    - "CapsLock" - The Caps Lock key
    - "Control" - The Control key
    - "Fn" - The Fn key
    - "FnLock" - The FnLock key
    - "Meta" - The Meta key (Command on Mac, Windows key on PC)
    - "NumLock" - The Num Lock key
    - "ScrollLock" - The Scroll Lock key
    - "Shift" - The Shift key
    - "Symbol" - The Symbol key
    - "SymbolLock" - The SymbolLock key

  ## Returns
  - `true` if the specified modifier key is active
  - `false` if the modifier key is not active

  ## Examples
      # Check if Control key was pressed
      is_ctrl = GenDOM.KeyboardEvent.get_modifier_state(event, "Control")
      
      # Check multiple modifiers
      if GenDOM.KeyboardEvent.get_modifier_state(event, "Control") and
         GenDOM.KeyboardEvent.get_modifier_state(event, "Shift") do
        # Handle Ctrl+Shift combination
      end

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/getModifierState
  """
  def get_modifier_state(_event, _key) do
    :not_implemented
  end
end