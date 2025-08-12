defmodule GenDOM.AnimationEvent do
  @moduledoc """
  Represents events related to CSS animations.

  The AnimationEvent interface represents events providing information related to CSS animations.
  These events are fired when CSS animations start, end, or iterate, allowing JavaScript to
  react to different stages of an animation's lifecycle.

  ## Specification Compliance

  This module implements the AnimationEvent interface as defined by:
  - **CSS Animations Level 1**: https://www.w3.org/TR/css-animations-1/#interface-animationevent
  - **MDN AnimationEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/AnimationEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.AnimationEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`

  ## Properties

  ### Animation Information
  - `animation_name` - The value of the animation-name CSS property that triggered the animation
  - `elapsed_time` - The amount of time the animation has been running, in seconds
  - `pseudo_element` - The name of the pseudo-element the animation runs on (e.g., "::before", "::after")

  ## Event Types

  AnimationEvent is used for the following event types:
  - `animationstart` - Fired when a CSS animation has started
  - `animationend` - Fired when a CSS animation has completed
  - `animationiteration` - Fired when an iteration of a CSS animation ends and another begins
  - `animationcancel` - Fired when a CSS animation unexpectedly aborts

  ## Usage

  AnimationEvent allows developers to synchronize JavaScript behavior with CSS animations,
  enabling complex animation sequences and providing hooks for animation lifecycle management.

  ## Examples

      # Creating an AnimationEvent
      event = GenDOM.AnimationEvent.new("animationstart", %{
        animation_name: "slide-in",
        elapsed_time: 0.0,
        pseudo_element: ""
      })

      # Handling animation events
      case event.type do
        "animationstart" ->
          IO.puts("Animation \#{event.animation_name} started")
        "animationend" ->
          IO.puts("Animation completed after \#{event.elapsed_time} seconds")
        "animationiteration" ->
          IO.puts("Animation iteration completed")
      end
  """

  use GenDOM.Event, [
    # The name of the CSS animation
    animation_name: "",            # Value of animation-name CSS property
    
    # Time information
    elapsed_time: 0.0,            # Time in seconds since animation started
    
    # Pseudo-element selector
    pseudo_element: ""            # Pseudo-element the animation runs on (e.g., "::before")
  ]
end
