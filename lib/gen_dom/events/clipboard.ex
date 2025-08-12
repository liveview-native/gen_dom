defmodule GenDOM.ClipboardEvent do
  @moduledoc """
  Represents events related to clipboard operations.

  The ClipboardEvent interface represents events providing information related to
  modification of the clipboard, including cut, copy, and paste operations. These events
  allow web applications to customize clipboard behavior and integrate with system clipboard.

  ## Specification Compliance

  This module implements the ClipboardEvent interface as defined by:
  - **Clipboard API and events**: https://www.w3.org/TR/clipboard-apis/#clipboardevent
  - **MDN ClipboardEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/ClipboardEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.ClipboardEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`

  ## Properties

  ### Clipboard Data
  - `clipboard_data` - DataTransfer object containing the data affected by the clipboard operation

  ## Event Types

  ClipboardEvent is used for the following event types:
  - `cut` - User initiated a cut operation
  - `copy` - User initiated a copy operation
  - `paste` - User initiated a paste operation

  ## Security Considerations

  - Clipboard access requires user interaction (cannot be triggered programmatically without user action)
  - Paste events may have restricted access to clipboard data for security reasons
  - Some browsers require secure context (HTTPS) for clipboard operations
  - Cross-origin restrictions may apply to clipboard data

  ## DataTransfer Object

  The `clipboard_data` property provides:
  - Access to data being cut, copied, or pasted
  - Support for multiple data formats (text, HTML, images, etc.)
  - MIME type information for the data

  ## Examples

      # Creating a ClipboardEvent
      event = GenDOM.ClipboardEvent.new("copy", %{
        clipboard_data: data_transfer_object,
        bubbles: true,
        cancelable: true
      })

      # Handling clipboard events
      case event.type do
        "copy" ->
          # Custom copy behavior
          Event.prevent_default(event)
          selection = get_selection()
          DataTransfer.set_data(event.clipboard_data, "text/plain", selection)
          DataTransfer.set_data(event.clipboard_data, "text/html", formatted_selection)
          
        "cut" ->
          # Custom cut behavior
          Event.prevent_default(event)
          selection = get_selection()
          DataTransfer.set_data(event.clipboard_data, "text/plain", selection)
          delete_selection()
          
        "paste" ->
          # Custom paste behavior
          Event.prevent_default(event)
          text = DataTransfer.get_data(event.clipboard_data, "text/plain")
          html = DataTransfer.get_data(event.clipboard_data, "text/html")
          insert_content(text, html)
      end

      # Checking available data types
      types = DataTransfer.types(event.clipboard_data)
      if "text/html" in types do
        html_content = DataTransfer.get_data(event.clipboard_data, "text/html")
        process_html(html_content)
      end
  """

  use GenDOM.Event, [
    # DataTransfer object containing clipboard data
    clipboard_data: nil           # Data affected by cut, copy, or paste operation
  ]
end
