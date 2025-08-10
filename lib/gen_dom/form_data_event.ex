defmodule GenDOM.FormDataEvent do
  @moduledoc """
  Represents a formdata event fired after the form data entry list is constructed.

  The FormDataEvent interface represents a `formdata` event that is fired on an HTMLFormElement
  object after the entry list representing the form's data is constructed. This occurs when
  the form is being submitted or when the `FormData()` constructor is invoked.

  ## Specification Compliance

  This module implements the FormDataEvent interface as defined by:
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#the-formdataevent-interface
  - **MDN FormDataEvent Reference**: https://developer.mozilla.org/en-US/docs/Web/API/FormDataEvent

  ## Inheritance Chain

  ```
  GenDOM.Event (Base)
  └── GenDOM.FormDataEvent (extends Event)
  ```

  **Inherits from:** `GenDOM.Event`
  **File:** `lib/gen_dom/form_data_event.ex`

  ## Properties

  ### Form Data Properties
  - `form_data` - Contains the FormData object representing the form data when the event was fired

  ## Event Types

  FormDataEvent is fired for the `formdata` event type when:
  - Form is being submitted and form data is constructed
  - `FormData()` constructor is called with a form element
  - Form data entry list is built for transmission

  ## Usage

  FormDataEvent provides an opportunity to modify form data before it is submitted or processed.
  This is particularly useful for adding, removing, or transforming form fields dynamically,
  such as adding CSRF tokens, converting data formats, or implementing custom validation.

  ## Examples

      # Creating a FormDataEvent with form data
      form_data = %FormData{}
      |> FormData.append("username", "john_doe")
      |> FormData.append("email", "john@example.com")
      
      event = GenDOM.FormDataEvent.new("formdata", %{
        form_data: form_data,
        bubbles: true,
        cancelable: false
      })

      # Accessing and modifying form data
      form_data = event.form_data
      
      # Add CSRF token
      updated_form_data = FormData.append(form_data, "csrf_token", get_csrf_token())
      
      # Modify existing field
      final_form_data = FormData.set(updated_form_data, "username", 
        String.downcase(FormData.get(updated_form_data, "username")))

      # Event for contact form submission
      contact_event = GenDOM.FormDataEvent.new("formdata", %{
        form_data: %FormData{}
        |> FormData.append("name", "Jane Smith")
        |> FormData.append("message", "Hello, world!")
        |> FormData.append("timestamp", DateTime.utc_now() |> DateTime.to_iso8601())
      })

      # File upload form event
      upload_event = GenDOM.FormDataEvent.new("formdata", %{
        form_data: %FormData{}
        |> FormData.append("title", "My Document")
        |> FormData.append("file", file_blob, "document.pdf")
        |> FormData.append("upload_type", "document")
      })

      # Dynamic form modification example
      dynamic_event = GenDOM.FormDataEvent.new("formdata", %{
        form_data: %FormData{}
        |> FormData.append("user_id", "123")
        |> FormData.append("preferences", Jason.encode!(%{theme: "dark", lang: "en"}))
      })

      # Processing form data in event handler
      def handle_form_data_event(event) do
        form_data = event.form_data
        
        # Add server-side validation token
        enhanced_data = FormData.append(form_data, "validation_token", generate_token())
        
        # Convert specific fields
        if FormData.has?(enhanced_data, "price") do
          price_str = FormData.get(enhanced_data, "price")
          case Decimal.parse(price_str) do
            {decimal_price, _} ->
              FormData.set(enhanced_data, "price_cents", 
                Decimal.mult(decimal_price, 100) |> Decimal.to_integer())
            :error ->
              FormData.append(enhanced_data, "errors", "Invalid price format")
          end
        else
          enhanced_data
        end
      end
  """

  use GenDOM.Event, [
    # Contains the FormData object representing form data when event was fired
    form_data: nil                # FormData object with form field data
  ]
end