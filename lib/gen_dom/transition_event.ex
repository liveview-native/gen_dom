defmodule GenDOM.TransitionEvent do
  @moduledoc """
  Represents events related to CSS Transitions.

  The TransitionEvent interface represents events sent as a result of CSS Transitions.
  These events provide information about which CSS property is being transitioned,
  how long the transition has been running, and which pseudo-element (if any) is being animated.

  ## Specification Compliance

  This module implements the TransitionEvent interface as defined by:
  - **CSS Transitions Level 1**: https://www.w3.org/TR/css-transitions-1/#Events-TransitionEvent
  - **MDN TransitionEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/TransitionEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.TransitionEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/transition_event.ex`

  ## Properties

  ### Transition Information Properties
  - `property_name` - String containing the CSS property associated with the transition
  - `elapsed_time` - Float representing seconds the transition has been running
  - `pseudo_element` - String with the name of the pseudo-element running the animation

  ## Event Types

  TransitionEvent is fired for these CSS transition-related events:
  - `transitionrun` - Fired when a transition is created (before delay)
  - `transitionstart` - Fired when a transition begins transitioning (after delay)
  - `transitionend` - Fired when a CSS transition finishes
  - `transitioncancel` - Fired when a CSS transition is cancelled

  ## Usage

  TransitionEvent allows developers to respond to CSS transition lifecycle events,
  enabling coordination between CSS animations and JavaScript logic. The `elapsed_time`
  property provides timing information that excludes transition delay.

  ## Examples

      # Creating a TransitionEvent for transition completion
      {:ok, event} = GenDOM.TransitionEvent.new("transitionend", %{
        property_name: "opacity",
        elapsed_time: 0.5,
        pseudo_element: "",
        bubbles: true,
        cancelable: true
      })

      # Accessing transition information
      property = GenDOM.TransitionEvent.get(event.pid, :property_name)
      time = GenDOM.TransitionEvent.get(event.pid, :elapsed_time)
      IO.puts("Transition on \#{property} completed in \#{time}s")

      # Creating a transition start event
      {:ok, start_event} = GenDOM.TransitionEvent.new("transitionstart", %{
        property_name: "transform",
        elapsed_time: 0.0,
        pseudo_element: ""
      })

      # Creating a transition event on pseudo-element
      {:ok, pseudo_event} = GenDOM.TransitionEvent.new("transitionend", %{
        property_name: "background-color",
        elapsed_time: 0.25,
        pseudo_element: "::before"
      })

      # Multiple property transition
      {:ok, multi_event} = GenDOM.TransitionEvent.new("transitionend", %{
        property_name: "width",
        elapsed_time: 1.0,
        pseudo_element: ""
      })

      # Cancelled transition event
      {:ok, cancel_event} = GenDOM.TransitionEvent.new("transitioncancel", %{
        property_name: "height",
        elapsed_time: 0.1,
        pseudo_element: ""
      })
  """

  use GenDOM.Event, [
    # String containing the CSS property associated with the transition
    property_name: "",            # Name of the CSS property being transitioned
    
    # Float representing seconds the transition has been running
    elapsed_time: 0.0,            # Time in seconds (excluding transition-delay)
    
    # String with the name of the pseudo-element running the animation
    pseudo_element: ""            # Pseudo-element name (e.g., "::before") or empty string
  ]
end