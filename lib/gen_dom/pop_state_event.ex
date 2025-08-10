defmodule GenDOM.PopStateEvent do
  @moduledoc """
  Represents an interface for the popstate event.

  The PopStateEvent interface represents the popstate event, which is dispatched when
  the active history entry changes between two entries for the same document. This occurs
  when the user navigates through their session history via browser back/forward buttons
  or programmatic history manipulation.

  ## Specification Compliance

  This module implements the PopStateEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/nav-history-apis.html#the-popstateevent-interface
  - **MDN PopStateEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/PopStateEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.PopStateEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/pop_state_event.ex`

  ## Properties

  ### History Navigation Properties
  - `state` - Returns a copy of information provided to pushState() or replaceState()
  - `has_ua_visual_transition` - Returns true if user agent performed a visual transition

  ## Event Types

  PopStateEvent is fired for the `popstate` event type when:
  - User clicks browser back/forward buttons
  - `history.back()`, `history.forward()`, or `history.go()` is called
  - Navigation occurs between history entries for the same document

  ## Usage

  PopStateEvent is essential for single-page applications (SPAs) using the HTML5 History API.
  It enables applications to respond to navigation events and update their state accordingly
  without full page reloads. The `state` property contains application-specific data
  associated with the history entry.

  ## Examples

      # Creating a PopStateEvent with state data
      event = GenDOM.PopStateEvent.new("popstate", %{
        state: %{
          page: "dashboard",
          user_id: 123,
          tab: "overview"
        },
        has_ua_visual_transition: false,
        bubbles: true,
        cancelable: false
      })

      # Accessing navigation state
      state = event.state
      has_transition = event.has_ua_visual_transition
      
      case state do
        %{page: page, user_id: user_id} ->
          IO.puts("Navigated to \#{page} for user \#{user_id}")
        nil ->
          IO.puts("Navigated to initial state")
        _ ->
          IO.puts("Navigated with custom state: \#{inspect(state)}")
      end

      # Creating a PopStateEvent for initial page load (state is typically null)
      initial_event = GenDOM.PopStateEvent.new("popstate", %{
        state: nil,
        has_ua_visual_transition: true
      })

      # SPA routing with complex state
      spa_event = GenDOM.PopStateEvent.new("popstate", %{
        state: %{
          route: "/products/123",
          params: %{category: "electronics", sort: "price"},
          scroll_position: 150
        }
      })

      # Browser navigation event
      nav_event = GenDOM.PopStateEvent.new("popstate", %{
        state: %{
          component: "ProductDetail",
          id: "prod-456",
          previous_route: "/catalog"
        },
        has_ua_visual_transition: true
      })

      # History API manipulation result
      history_event = GenDOM.PopStateEvent.new("popstate", %{
        state: %{
          modal: "settings",
          background_route: "/dashboard",
          timestamp: DateTime.utc_now() |> DateTime.to_unix()
        }
      })
  """

  use GenDOM.Event, [
    # Returns a copy of information provided to pushState() or replaceState()
    state: nil,                   # Application state data from history entry
    
    # Returns true if user agent performed a visual transition
    has_ua_visual_transition: false # Whether browser performed visual transition
  ]
end