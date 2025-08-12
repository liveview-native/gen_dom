defmodule GenDOM.ErrorEvent do
  @moduledoc """
  Represents events providing information about errors.

  The ErrorEvent interface represents events providing information about errors in scripts
  or in files. This includes JavaScript runtime errors, syntax errors, and errors loading
  external resources.

  ## Specification Compliance

  This module implements the ErrorEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/webappapis.html#errorevent
  - **MDN ErrorEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/ErrorEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.ErrorEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`

  ## Properties

  ### Error Information
  - `message` - Human-readable error message describing the problem
  - `filename` - Name of the script file where the error occurred
  - `lineno` - Line number where the error occurred
  - `colno` - Column number where the error occurred
  - `error` - The actual error object (Error, DOMException, etc.)

  ## Event Types

  ErrorEvent is used for:
  - `error` - Script error or resource loading error
  - `unhandledrejection` - Unhandled Promise rejection (uses PromiseRejectionEvent)

  ## Error Sources

  Errors can originate from:
  - JavaScript runtime errors
  - Syntax errors in scripts
  - Failed resource loading (images, scripts, stylesheets)
  - Unhandled promise rejections
  - Worker script errors

  ## Usage Notes

  - Global error handlers can catch unhandled errors
  - The `error` property contains the actual Error object when available
  - Cross-origin scripts may have limited error information for security
  - Can be used in both main thread and Web Workers

  ## Examples

      # Creating an ErrorEvent
      event = GenDOM.ErrorEvent.new("error", %{
        message: "Uncaught ReferenceError: foo is not defined",
        filename: "/js/app.js",
        lineno: 42,
        colno: 13,
        error: error_object,
        bubbles: false,
        cancelable: true
      })

      # Handling error events
      case event.type do
        "error" ->
          Logger.error("JavaScript Error: \#{event.message}")
          Logger.error("  at \#{event.filename}:\#{event.lineno}:\#{event.colno}")
          
          if event.error do
            Logger.error("  Stack trace: \#{event.error.stack}")
          end
          
          # Prevent default error handling
          Event.prevent_default(event)
      end

      # Global error handler setup
      Window.add_event_listener(window, "error", fn event ->
        report_error_to_server(%{
          message: event.message,
          source: event.filename,
          line: event.lineno,
          column: event.colno,
          error: serialize_error(event.error)
        })
      end)
  """

  use GenDOM.Event, [
    # Error details
    message: "",                  # Human-readable error message
    filename: "",                 # Script file where error occurred
    lineno: 0,                    # Line number of error
    colno: 0,                     # Column number of error
    error: nil                    # The actual Error object or value
  ]
end
