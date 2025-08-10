defmodule GenDOM.ProgressEvent do
  @moduledoc """
  Represents events measuring progress of an underlying process.

  The ProgressEvent interface represents events measuring progress of an underlying process,
  like HTTP requests, resource loading, or any operation that can report progress information.
  It provides information about how much work has been done and the total amount of work.

  ## Specification Compliance

  This module implements the ProgressEvent interface as defined by:
  - **XMLHttpRequest Standard**: https://xhr.spec.whatwg.org/#interface-progressevent
  - **MDN ProgressEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/ProgressEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.ProgressEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/progress_event.ex`

  ## Properties

  ### Progress Information Properties
  - `length_computable` - Boolean indicating if the progress ratio is calculable
  - `loaded` - Number representing the size of data transmitted/processed
  - `total` - Number indicating the total data size being transmitted

  ## Event Types

  ProgressEvent is used for various progress-related events:
  - `loadstart` - Progress started
  - `progress` - Progress is being made
  - `abort` - Progress was aborted
  - `error` - Progress failed due to error  
  - `load` - Progress completed successfully
  - `timeout` - Progress timed out
  - `loadend` - Progress ended (regardless of success/failure)

  ## Usage

  ProgressEvent is commonly used in XMLHttpRequest operations, file uploads,
  resource loading, and any scenario where progress feedback is valuable to users.
  The `length_computable` property determines if meaningful progress ratios can be calculated.

  ## Examples

      # Creating a ProgressEvent for file upload
      {:ok, event} = GenDOM.ProgressEvent.new("progress", %{
        length_computable: true,
        loaded: 2048,
        total: 8192,
        bubbles: true
      })

      # Accessing progress information
      if GenDOM.ProgressEvent.get(event.pid, :length_computable) do
        loaded = GenDOM.ProgressEvent.get(event.pid, :loaded)
        total = GenDOM.ProgressEvent.get(event.pid, :total)
        percentage = (loaded / total * 100) |> round()
        IO.puts("Progress: \#{percentage}%")
      end

      # Creating a load start event
      {:ok, start_event} = GenDOM.ProgressEvent.new("loadstart", %{
        length_computable: false,
        loaded: 0,
        total: 0
      })

      # Creating a completion event
      {:ok, load_event} = GenDOM.ProgressEvent.new("load", %{
        length_computable: true,
        loaded: 1024,
        total: 1024
      })

      # HTTP request progress event
      {:ok, http_progress} = GenDOM.ProgressEvent.new("progress", %{
        length_computable: true,
        loaded: 51200,  # 50KB loaded
        total: 102400,  # 100KB total
        bubbles: false
      })

      # Indeterminate progress (total unknown)
      {:ok, indeterminate} = GenDOM.ProgressEvent.new("progress", %{
        length_computable: false,
        loaded: 1500,
        total: 0
      })
  """

  use GenDOM.Event, [
    # Boolean indicating if progress ratio is calculable
    length_computable: false,     # Whether meaningful progress can be calculated
    
    # Number representing size of data transmitted/processed
    loaded: 0,                    # Amount of work already performed
    
    # Number indicating total data size being transmitted
    total: 0                      # Total amount of work to be performed
  ]
end