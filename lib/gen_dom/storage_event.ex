defmodule GenDOM.StorageEvent do
  @moduledoc """
  Represents events fired when a storage area changes within the context of another document.

  The StorageEvent interface represents events fired when a storage area (localStorage or
  sessionStorage) is changed within the context of another document. This allows different
  windows/tabs to be notified of storage changes and stay synchronized.

  ## Specification Compliance

  This module implements the StorageEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/webstorage.html#the-storageevent-interface
  - **MDN StorageEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.StorageEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/storage_event.ex`

  ## Properties

  ### Storage Change Properties
  - `key` - String representing the storage item's key that was changed (null if storage.clear())
  - `new_value` - String with the new value of the changed storage item (null if removed)
  - `old_value` - String with the original value of the changed storage item (null if new)
  - `storage_area` - Storage object representing the affected storage (localStorage/sessionStorage)
  - `url` - String with the URL of the document whose storage changed

  ## Event Types

  StorageEvent is fired for the `storage` event type when:
  - A storage item is added, modified, or removed
  - `storage.clear()` is called
  - Changes occur in localStorage or sessionStorage from another document

  ## Usage

  StorageEvent enables cross-tab/cross-window communication by notifying other documents
  when storage changes occur. This is useful for keeping application state synchronized
  across multiple browser contexts.

  ## Examples

      # Creating a StorageEvent for item modification
      event = GenDOM.StorageEvent.new("storage", %{
        key: "user_preference",
        old_value: "dark",
        new_value: "light",
        storage_area: local_storage,
        url: "https://example.com/settings"
      })

      # Accessing storage change information
      key = event.key
      old_val = event.old_value
      new_val = event.new_value
      IO.puts("Storage key '\#{key}' changed from '\#{old_val}' to '\#{new_val}'")

      # Creating a StorageEvent for new item
      new_item_event = GenDOM.StorageEvent.new("storage", %{
        key: "session_token",
        old_value: nil,
        new_value: "abc123xyz",
        storage_area: local_storage,
        url: "https://example.com/login"
      })

      # Creating a StorageEvent for removed item
      removed_event = GenDOM.StorageEvent.new("storage", %{
        key: "temp_data",
        old_value: "temporary_value",
        new_value: nil,
        storage_area: session_storage,
        url: "https://example.com/app"
      })

      # Creating a StorageEvent for storage.clear()
      clear_event = GenDOM.StorageEvent.new("storage", %{
        key: nil,
        old_value: nil,
        new_value: nil,
        storage_area: local_storage,
        url: "https://example.com/reset"
      })

      # Cross-document storage synchronization
      sync_event = GenDOM.StorageEvent.new("storage", %{
        key: "shared_state",
        old_value: %{count: 5} |> Jason.encode!(),
        new_value: %{count: 6} |> Jason.encode!(),
        storage_area: local_storage,
        url: "https://example.com/counter"
      })
  """

  use GenDOM.Event, [
    # String representing the storage item's key that was changed
    key: nil,                     # Storage key (null if storage.clear() was called)
    
    # String with the new value of the changed storage item
    new_value: nil,               # New value (null if item was removed)
    
    # String with the original value of the changed storage item
    old_value: nil,               # Original value (null if item was newly added)
    
    # Storage object representing the affected storage
    storage_area: nil,            # localStorage or sessionStorage reference
    
    # String with the URL of the document whose storage changed
    url: ""                       # URL of the document that made the change
  ]

  @doc """
  Initializes the values of a StorageEvent.

  This method implements the StorageEvent `initStorageEvent()` specification. It initializes
  a StorageEvent that was created using the deprecated Document.createEvent() method.

  ## Deprecation Notice
  **This method is deprecated.** Use the StorageEvent() constructor instead to create
  and initialize storage events. This method is maintained only for backward compatibility
  with legacy code.

  ## Parameters
  - `event` - The StorageEvent struct to initialize
  - `type` - A string defining the type of event (typically "storage")
  - `can_bubble` - A boolean indicating whether the event can bubble up through the DOM
  - `cancelable` - A boolean indicating whether the event's default action can be prevented
  - `key` - The storage key that was changed
  - `old_value` - The previous value of the key
  - `new_value` - The new value of the key
  - `url` - The URL of the document whose key was changed
  - `storage_area` - The Storage object that was affected

  ## Returns
  Returns `:not_implemented` (would normally return undefined/nil)

  ## Examples
      # Legacy code example (deprecated - do not use in new code)
      event = Document.create_event(document, "StorageEvent")
      GenDOM.StorageEvent.init_storage_event(event,
        "storage",                # type
        false,                    # can_bubble
        false,                    # cancelable
        "user_setting",           # key
        "old_value",              # old_value
        "new_value",              # new_value
        "https://example.com",    # url
        local_storage             # storage_area
      )

  ## Modern Alternative
  Instead of using this deprecated method, create StorageEvent instances directly:

      event = GenDOM.StorageEvent.new("storage", %{
        bubbles: false,
        cancelable: false,
        key: "user_setting",
        old_value: "old_value",
        new_value: "new_value",
        url: "https://example.com",
        storage_area: local_storage
      })

  ## MDN Reference
  https://developer.mozilla.org/en-US/docs/Web/API/StorageEvent/initStorageEvent
  """
  def init_storage_event(_event, _type, _can_bubble, _cancelable, _key, _old_value, _new_value, _url, _storage_area) do
    :not_implemented
  end
end