defmodule GenDOM.SubmitEvent do
  @moduledoc """
  Represents the event object for form submission.

  The SubmitEvent interface represents the event object for the `submit` event, which
  is fired when a form's submit action is invoked. This event provides information about
  which element (if any) was responsible for triggering the form submission.

  ## Specification Compliance

  This module implements the SubmitEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#the-submitevent-interface
  - **MDN SubmitEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/SubmitEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.SubmitEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/submit_event.ex`

  ## Properties

  ### Form Submission Properties
  - `submitter` - HTMLElement that triggered the form submission (button, input type="submit", etc.)

  ## Event Types

  SubmitEvent is fired for the `submit` event type when:
  - User clicks a submit button
  - User presses Enter in a form field
  - Form submission is triggered programmatically
  - Input with type="image" is clicked

  ## Usage

  SubmitEvent allows form handling code to determine exactly which element triggered
  the submission, enabling different behaviors based on the submitter. This is particularly
  useful for forms with multiple submit buttons or when different submission logic
  is needed based on the trigger element.

  ## Examples

      # Creating a SubmitEvent with submitter information
      event = GenDOM.SubmitEvent.new("submit", %{
        submitter: submit_button_element,
        bubbles: true,
        cancelable: true
      })

      # Accessing submitter information
      submitter = event.submitter
      
      case GenDOM.Element.get_attribute(submitter, "name") do
        "save" -> IO.puts("Form submitted with save action")
        "draft" -> IO.puts("Form submitted as draft")
        "delete" -> IO.puts("Form submitted for deletion")
        _ -> IO.puts("Form submitted with default action")
      end

      # Form with multiple submit buttons
      multi_button_event = GenDOM.SubmitEvent.new("submit", %{
        submitter: save_and_continue_button,
        cancelable: true
      })

      # Programmatic form submission (submitter may be null)
      programmatic_event = GenDOM.SubmitEvent.new("submit", %{
        submitter: nil,
        bubbles: true,
        cancelable: true
      })

      # Image input submission
      image_event = GenDOM.SubmitEvent.new("submit", %{
        submitter: image_input_element,
        cancelable: true
      })

      # Enter key submission in text field
      enter_event = GenDOM.SubmitEvent.new("submit", %{
        submitter: text_input_element,
        bubbles: true,
        cancelable: true
      })

      # AJAX form submission with specific button context
      ajax_event = GenDOM.SubmitEvent.new("submit", %{
        submitter: ajax_submit_button,
        cancelable: true
      })
      
      # Process based on submitter
      submitter_id = GenDOM.Element.get_attribute(
        ajax_event.submitter, 
        "id"
      )
      
      case submitter_id do
        "quick-save" -> handle_quick_save()
        "full-save" -> handle_full_save()
        "save-and-exit" -> handle_save_and_exit()
      end
  """

  use GenDOM.Event, [
    # HTMLElement that triggered the form submission
    submitter: nil                # The button or input that caused submission
  ]
end