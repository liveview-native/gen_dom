defmodule GenDOM.HashChangeEvent do
  @moduledoc """
  Represents events fired when the fragment identifier of the URL has changed.

  The HashChangeEvent interface represents events fired when the fragment identifier
  (the part of the URL beginning with and following the # symbol) of the document has changed.
  This enables applications to respond to hash changes for client-side routing and navigation.

  ## Specification Compliance

  This module implements the HashChangeEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/nav-history-apis.html#the-hashchangeevent-interface
  - **MDN HashChangeEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/HashChangeEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.HashChangeEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`

  ## Properties

  ### URL Change Properties
  - `new_url` - The new URL to which the window is navigating
  - `old_url` - The previous URL from which the window was navigated

  ## Event Types

  HashChangeEvent is fired for the `hashchange` event type when:
  - The URL hash fragment changes via user interaction (clicking hash links)
  - The hash is modified programmatically (location.hash = "new-hash")
  - Navigation occurs between hash-based routes

  ## Usage

  HashChangeEvent is fundamental for client-side routing applications that use URL hashes
  to manage navigation state. It allows applications to respond to both user-initiated
  and programmatic hash changes while maintaining browser history.

  ## Examples

      # Creating a HashChangeEvent for navigation
      event = GenDOM.HashChangeEvent.new("hashchange", %{
        old_url: "https://example.com/page#section1",
        new_url: "https://example.com/page#section2",
        bubbles: true,
        cancelable: false
      })

      # Accessing URL change information
      old_url = event.old_url
      new_url = event.new_url
      
      old_hash = URI.parse(old_url).fragment || ""
      new_hash = URI.parse(new_url).fragment || ""
      IO.puts("Hash changed from '\#{old_hash}' to '\#{new_hash}'")

      # Creating a HashChangeEvent for initial hash
      initial_event = GenDOM.HashChangeEvent.new("hashchange", %{
        old_url: "https://example.com/app",
        new_url: "https://example.com/app#home"
      })

      # Single-page application routing
      spa_event = GenDOM.HashChangeEvent.new("hashchange", %{
        old_url: "https://myapp.com/#/dashboard",
        new_url: "https://myapp.com/#/profile"
      })

      # Hash removal event
      removal_event = GenDOM.HashChangeEvent.new("hashchange", %{
        old_url: "https://example.com/docs#api",
        new_url: "https://example.com/docs"
      })

      # Complex hash with parameters
      complex_event = GenDOM.HashChangeEvent.new("hashchange", %{
        old_url: "https://app.com/#/user/123/edit",
        new_url: "https://app.com/#/user/123/view"
      })
  """

  use GenDOM.Event, [
    # The new URL to which the window is navigating
    new_url: "",                  # Complete URL with new hash fragment
    
    # The previous URL from which the window was navigated
    old_url: ""                   # Complete URL with previous hash fragment
  ]
end
