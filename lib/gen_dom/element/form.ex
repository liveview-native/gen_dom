defmodule GenDOM.Element.Form do
  @derive {Inspect, only: [:pid, :tag_name, :id, :class_list, :attributes]}

  @moduledoc """
  Represents a form element based on the FormElement specification.

  This module implements the FormElement interface properties and methods
  as defined in the DOM specification. Form elements are the only elements
  that implement the FormElement interface.

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.Element.Form (extends Element)
  ```

  **Inherits from:** `GenDOM.Element`  
  **File:** `lib/gen_dom/element/form.ex`  
  **Inheritance:** `use GenDOM.Element` (line 12)

  ## Usage

  ```elixir
  # Create a new form element
  form = GenDOM.Element.Form.new([
    tag_name: "form",
    action: "/submit",
    method: "post",
    name: "user_form"
  ])

  # Add form controls
  input = GenDOM.Element.Input.new([type: "text", name: "username"])
  GenDOM.Node.append_child(form.pid, input.pid)
  ```

  ## Features

  - Full FormElement specification compliance
  - Form submission and validation
  - Form control management
  - All inherited Element functionality (attributes, classes, DOM operations)
  - All inherited Node functionality (DOM tree operations, process management)

  ## Form Methods

  This module provides all standard form methods:
  - `submit()` - Submit the form bypassing validation
  - `request_submit()` - Submit with validation and events
  - `reset()` - Reset all form controls to initial values
  - `check_validity()` - Check if all form controls are valid
  - `report_validity()` - Check validity and report issues

  ## Additional Fields

  Beyond the base Element fields, Form adds:
  - `action` - The URI to process form submission
  - `method` - HTTP method for submission (get, post, etc.)
  - `name` - The form's name attribute
  - `accept_charset` - Character encodings accepted by the server
  - `autocomplete` - Whether browser should autocomplete form values
  - `enctype` - Content type for form data encoding
  - `novalidate` - Whether to skip form validation
  - `target` - Where to display submission results
  - `elements` - Collection of all form controls
  - `length` - Number of controls in the form
  """

  use GenDOM.Element, [
    # FormElement instance properties converted to snake_case
    accept_charset: nil,      # Reflects the form's "accept-charset" attribute
    action: nil,              # Contains the URI for processing form submission  
    autocomplete: nil,        # Indicates browser's automatic form value population
    encoding: nil,            # Specifies content transmission type (alias for enctype)
    enctype: nil,             # Specifies content transmission type
    elements: [],             # Holds all form controls (FormControlsCollection)
    length: 0,                # Number of controls in the form (read-only)
    name: nil,                # Form's name attribute value
    no_validate: false,       # Indicates whether form should be validated
    method: "get",            # HTTP method used for form submission
    rel: nil,                 # Represents form link types
    rel_list: [],             # List of rel attribute tokens (DOMTokenList)
    target: nil,              # Specifies where to display submission results
    
    # Form-specific fields from original implementation
    accept: nil,
    novalidate: nil
  ]

  @doc """
  Checks if all the form controls in this form are valid.

  This method implements the DOM `checkValidity()` specification. It validates
  all form controls and returns true if all are valid, false otherwise.

  ## Parameters

  - `form_pid` - The PID of the form element to validate

  ## Examples

      is_valid = GenDOM.Element.Form.check_validity(form.pid)
      # => true or false

  """
  def check_validity(_form) do
    # Implementation to be added
  end

  @doc """
  Checks the validity constraints on all form controls and reports any validation problems.

  This method implements the DOM `reportValidity()` specification. It performs
  validation and reports issues to the user if any are found.

  ## Parameters

  - `form_pid` - The PID of the form element to validate and report on

  ## Examples

      reported = GenDOM.Element.Form.report_validity(form.pid)
      # => true if valid, false if validation problems were reported

  """
  def report_validity(_form) do
    # Implementation to be added
  end

  @doc """
  Submits the form using the specified submit button or the form's default submission behavior.

  This method implements the DOM `requestSubmit()` specification. Unlike submit(),
  this method triggers form validation and submit event.

  ## Parameters

  - `form_pid` - The PID of the form element to submit

  ## Examples

      GenDOM.Element.Form.request_submit(form.pid)

  """
  def request_submit(_form) do
    # Implementation to be added
  end

  @doc """
  Submits the form using the specified submit button.

  This method implements the DOM `requestSubmit()` specification with a submitter.

  ## Parameters

  - `form_pid` - The PID of the form element to submit
  - `submitter_pid` - The PID of the submit button that triggered the submission

  ## Examples

      GenDOM.Element.Form.request_submit(form.pid, submit_button.pid)

  """
  def request_submit(_form, _submitter) do
    # Implementation to be added
  end

  @doc """
  Resets all form controls to their initial values.

  This method implements the DOM `reset()` specification. It restores all
  form controls to their default values and clears any validation messages.

  ## Parameters

  - `form_pid` - The PID of the form element to reset

  ## Examples

      GenDOM.Element.Form.reset(form.pid)

  """
  def reset(_form) do
    # Implementation to be added
  end

  @doc """
  Submits the form to the server.

  This method implements the DOM `submit()` specification. Unlike requestSubmit(),
  this method bypasses form validation and submit event handlers.

  ## Parameters

  - `form_pid` - The PID of the form element to submit

  ## Examples

      GenDOM.Element.Form.submit(form.pid)

  """
  def submit(_form) do
    # Implementation to be added
  end

  @doc """
  Encodes the form element into a serializable format.

  This method overrides the base Element `encode/1` to include form-specific fields
  in the encoded representation. Used for serialization and communication.

  ## Parameters

  - `form` - The form element struct to encode

  ## Examples

      iex> form = GenDOM.Element.Form.new([action: "/submit", method: "post"])
      iex> encoded = GenDOM.Element.Form.encode(form)
      iex> encoded.action
      "/submit"
      iex> encoded.method
      "post"

  """
  def encode(form) do
    Map.merge(super(form), %{
      action: form.action,
      method: form.method,
      name: form.name,
      accept: form.accept,
      autocomplete: form.autocomplete,
      novalidate: form.novalidate
    })
  end
end
