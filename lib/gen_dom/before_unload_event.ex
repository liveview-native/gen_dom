defmodule GenDOM.BeforeUnloadEvent do
  @moduledoc """
  Represents the event object for the beforeunload event.

  The BeforeUnloadEvent interface represents the event object for the `beforeunload` event,
  which is fired when the current window, contained document, and associated resources are
  about to be unloaded. This event provides a way to warn users about unsaved changes before
  they navigate away from a page.

  ## Specification Compliance

  This module implements the BeforeUnloadEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/nav-history-apis.html#the-beforeunloadevent-interface
  - **MDN BeforeUnloadEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/BeforeUnloadEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.BeforeUnloadEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/before_unload_event.ex`

  ## Properties

  ### Unload Control Properties
  - `return_value` - When set to a truthy value, triggers a browser confirmation dialog (deprecated)

  ## Event Types

  BeforeUnloadEvent is used for the `beforeunload` event type, fired when:
  - User attempts to navigate away from the page
  - User tries to close the tab/window
  - User refreshes the page
  - Navigation is triggered programmatically

  ## Usage

  BeforeUnloadEvent allows applications to intercept navigation attempts and prompt users
  to confirm their intent, particularly when there might be unsaved changes. Modern best
  practice is to use `event.preventDefault()` instead of the deprecated `returnValue` property.

  ## Examples

      # Creating a BeforeUnloadEvent
      {:ok, event} = GenDOM.BeforeUnloadEvent.new("beforeunload", %{
        cancelable: true,
        bubbles: false
      })

      # Legacy approach using return_value (deprecated)
      {:ok, legacy_event} = GenDOM.BeforeUnloadEvent.new("beforeunload", %{
        return_value: "You have unsaved changes. Are you sure you want to leave?",
        cancelable: true
      })

      # Modern approach - use preventDefault() instead
      # (This would be handled in the event listener, not in the event creation)

      # Page with unsaved changes warning
      {:ok, unsaved_event} = GenDOM.BeforeUnloadEvent.new("beforeunload", %{
        cancelable: true
      })
      
      # Note: In practice, you would use preventDefault() in the event handler:
      # def handle_before_unload(event) do
      #   if has_unsaved_changes?() do
      #     GenDOM.Event.prevent_default(event)
      #   end
      # end

      # Form with unsaved data protection
      {:ok, form_event} = GenDOM.BeforeUnloadEvent.new("beforeunload", %{
        cancelable: true,
        bubbles: false
      })
  """

  use GenDOM.Event, [
    # When set to truthy value, triggers browser confirmation dialog (deprecated)
    return_value: ""              # Deprecated: use preventDefault() instead
  ]
end