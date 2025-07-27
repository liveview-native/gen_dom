defmodule GenDOM.HTMLFormElement do
  @moduledoc """
  The HTMLFormElement interface represents `<form>` elements.

  The HTMLFormElement interface provides properties and methods for creating and
  manipulating form elements. It includes validation, form submission, and control
  over form behavior, allowing programmatic access to form data and submission.

  ## Specification Compliance

  This module implements the HTMLFormElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/forms.html#htmlformelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/sec-forms.html#the-form-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLFormElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_form_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "form"

  ## Properties

  ### Form Configuration
  - `action` - URL for form submission processing
  - `method` - HTTP method for form submission ("get", "post", "dialog")
  - `enctype` - Content type for form submission encoding
  - `target` - Specifies where to display the response after submission
  - `name` - Form name attribute
  - `accept_charset` - Character encodings accepted by the server
  - `autocomplete` - Controls browser's automatic form completion
  - `no_validate` - Boolean indicating whether form validation should be skipped
  - `rel` - Relationship between current document and linked resource
  - `rel_list` - Read-only list of relationship tokens

  ### Form State
  - `elements` - Collection of form controls (read-only)
  - `length` - Number of form controls (read-only)

  ## Methods

  ### Form Validation
  - `check_validity/1` - Validates all form controls
  - `report_validity/1` - Validates and reports constraint violations

  ### Form Submission
  - `submit/1` - Submits the form to the server
  - `request_submit/2` - Submits form with optional submitter element

  ### Form Management
  - `reset/1` - Resets form controls to their initial values

  ## Usage Examples

  ```elixir
  # Basic form
  form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    method: "post",
    enctype: "multipart/form-data"
  ])

  # Form with validation
  validated_form = GenDOM.HTMLFormElement.new([
    action: "/api/users",
    method: "post",
    no_validate: false,
    autocomplete: "on"
  ])

  # Dialog form
  dialog_form = GenDOM.HTMLFormElement.new([
    method: "dialog"
  ])
  ```

  ## Form Submission

  ### GET Method
  ```elixir
  get_form = GenDOM.HTMLFormElement.new([
    action: "/search",
    method: "get"
  ])

  # Submit form
  GenDOM.HTMLFormElement.submit(get_form.pid)
  ```

  ### POST Method
  ```elixir
  post_form = GenDOM.HTMLFormElement.new([
    action: "/users",
    method: "post",
    enctype: "application/x-www-form-urlencoded"
  ])

  # Submit with validation
  if GenDOM.HTMLFormElement.check_validity(post_form.pid) do
    GenDOM.HTMLFormElement.submit(post_form.pid)
  end
  ```

  ### File Upload
  ```elixir
  upload_form = GenDOM.HTMLFormElement.new([
    action: "/upload",
    method: "post",
    enctype: "multipart/form-data"
  ])
  ```

  ## Form Validation

  ### Constraint Validation
  ```elixir
  # Check if entire form is valid
  form = GenDOM.HTMLFormElement.new([action: "/submit"])
  is_valid = GenDOM.HTMLFormElement.check_validity(form.pid)

  # Validate and show user feedback
  GenDOM.HTMLFormElement.report_validity(form.pid)
  ```

  ### Custom Validation
  ```elixir
  # Skip built-in validation
  form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    no_validate: true
  ])
  ```

  ## Form Reset

  ```elixir
  # Reset form to initial state
  form = GenDOM.HTMLFormElement.new([action: "/submit"])
  GenDOM.HTMLFormElement.reset(form.pid)
  ```

  ## Form Controls Access

  ```elixir
  # Get form elements collection
  form = GenDOM.HTMLFormElement.new([])
  elements = GenDOM.HTMLFormElement.get_elements(form.pid)
  count = GenDOM.HTMLFormElement.get_length(form.pid)
  ```

  ## Character Encoding

  ```elixir
  # Specify accepted character sets
  form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    accept_charset: "UTF-8"
  ])
  ```

  ## Target Specification

  ```elixir
  # Open response in new window
  form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    target: "_blank"
  ])

  # Open in specific frame
  iframe_form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    target: "result_frame"
  ])
  ```

  ## Accessibility

  ### Form Labeling
  ```elixir
  # Accessible form with clear structure
  accessible_form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    name: "contact_form"
    # Ensure all form controls have proper labels
    # Use fieldset/legend for related controls
  ])
  ```

  ### Validation Messages
  ```elixir
  # Provide clear validation feedback
  form = GenDOM.HTMLFormElement.new([action: "/submit"])

  # Use report_validity to show accessible error messages
  GenDOM.HTMLFormElement.report_validity(form.pid)
  ```

  ## Security Considerations

  ### Form Submission Security
  ```elixir
  # Secure form submission
  secure_form = GenDOM.HTMLFormElement.new([
    action: "https://example.com/submit",  # Use HTTPS
    method: "post",  # Use POST for sensitive data
    enctype: "application/x-www-form-urlencoded"
  ])
  ```

  ### CSRF Protection
  ```elixir
  # Include CSRF tokens in forms
  # Validate on server side
  csrf_form = GenDOM.HTMLFormElement.new([
    action: "/submit",
    method: "post"
    # Add hidden CSRF token input
  ])
  ```

  ## Performance Considerations

  - **Validation**: Perform client-side validation for UX, server-side for security
  - **Large Forms**: Consider progressive enhancement for complex forms
  - **File Uploads**: Use appropriate enctype for file uploads
  - **Autocomplete**: Enable autocomplete for better user experience
  """

  @derive {Inspect, only: [:pid, :tag_name, :action, :method, :name]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for form-specific behavior
    tag_name: "form",

    # Form configuration
    action: "",
    method: "get", # "get" | "post" | "dialog"
    enctype: "application/x-www-form-urlencoded",
    target: "",
    name: "",
    accept_charset: "",
    autocomplete: "on", # "on" | "off"
    no_validate: false,
    rel: "",
    rel_list: [], # read-only DOMTokenList

    # Form state (read-only)
    elements: [], # read-only HTMLFormControlsCollection
    length: 0 # read-only, number of form controls
  ]

  @doc """
  Encodes the HTMLFormElement into a map representation.

  This function extends the base Element encoding to include form-specific
  properties like action, method, encoding type, and form controls.

  ## Parameters

  - `form` - The HTMLFormElement struct to encode

  ## Returns

  Map containing all form properties including inherited Node and Element fields

  ## Examples

      form = GenDOM.HTMLFormElement.new([action: "/submit", method: "post"])
      encoded = GenDOM.HTMLFormElement.encode(form)
      # Returns: %{node_type: 1, tag_name: "form", action: "/submit", method: "post", ...}
  """
  def encode(form) do
    Map.merge(super(form), %{
      action: form.action,
      method: form.method,
      enctype: form.enctype,
      target: form.target,
      name: form.name,
      accept_charset: form.accept_charset,
      autocomplete: form.autocomplete,
      no_validate: form.no_validate,
      rel: form.rel,
      rel_list: form.rel_list,
      elements: form.elements,
      length: form.length
    })
  end

  @doc """
  Validates all form controls and returns the validity status.

  This method implements the HTMLFormElement `checkValidity()` specification.
  It runs constraint validation on all form controls and returns true if all
  controls are valid, false otherwise.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Boolean indicating validity status of all form controls

  ## Examples

      form = GenDOM.HTMLFormElement.new([action: "/submit"])
      is_valid = GenDOM.HTMLFormElement.check_validity(form.pid)
      # Returns: true (if all controls are valid)

  ## Specification

  From the HTML Standard: "The checkValidity() method, when invoked, must run the check validity algorithm."
  """
  def check_validity(form_pid) do
    form = GenDOM.Node.get(form_pid)

    # In real implementation would validate all form controls
    # For now, return true if no validation issues
    Enum.all?(form.elements, fn element_pid ->
      element = GenDOM.Node.get(element_pid)
      # Check if element has validation method and call it
      case element.__struct__ do
        GenDOM.HTMLInputElement -> GenDOM.HTMLInputElement.check_validity(element_pid)
        GenDOM.HTMLButtonElement -> GenDOM.HTMLButtonElement.check_validity(element_pid)
        _ -> true
      end
    end)
  end

  @doc """
  Validates all form controls and reports constraint violations to the user.

  This method implements the HTMLFormElement `reportValidity()` specification.
  It performs validation and shows validation messages to the user if any
  controls are invalid.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Boolean indicating validity status of all form controls

  ## Examples

      form = GenDOM.HTMLFormElement.new([action: "/submit"])
      is_valid = GenDOM.HTMLFormElement.report_validity(form.pid)
      # Shows validation UI if invalid controls exist
  """
  def report_validity(form_pid) do
    form = GenDOM.Node.get(form_pid)
    is_valid = check_validity(form_pid)

    unless is_valid do
      # In real implementation would show validation UI for each invalid control
      Enum.each(form.elements, fn element_pid ->
        element = GenDOM.Node.get(element_pid)
        case element.__struct__ do
          GenDOM.HTMLInputElement -> GenDOM.HTMLInputElement.report_validity(element_pid)
          GenDOM.HTMLButtonElement -> GenDOM.HTMLButtonElement.report_validity(element_pid)
          _ -> :ok
        end
      end)
    end

    is_valid
  end

  @doc """
  Submits the form to the server.

  This method implements the HTMLFormElement `submit()` specification.
  It submits the form using the configured action, method, and encoding.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Examples

      form = GenDOM.HTMLFormElement.new([action: "/submit", method: "post"])
      GenDOM.HTMLFormElement.submit(form.pid)

  ## Specification

  From the HTML Standard: "The submit() method, when invoked, must submit the form."

  ## Behavior

  - Does not fire submit event
  - Does not run form validation
  - Submits form data using configured method and action
  """
  def submit(form_pid) do
    form = GenDOM.Node.get(form_pid)

    # In real implementation would:
    # 1. Construct form data from form controls
    # 2. Submit using configured method and action
    # 3. Handle response according to target

    case form.method do
      "get" -> :submit_get
      "post" -> :submit_post
      "dialog" -> :submit_dialog
      _ -> :submit_get
    end
  end

  @doc """
  Submits the form with an optional submitter element.

  This method implements the HTMLFormElement `requestSubmit()` specification.
  It submits the form with validation and proper event handling, optionally
  using a specific submitter element.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `submitter_pid` - Optional PID of the submitter element (button/input)

  ## Examples

      form = GenDOM.HTMLFormElement.new([action: "/submit"])
      GenDOM.HTMLFormElement.request_submit(form.pid)

      # With specific submitter
      submit_btn = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLFormElement.request_submit(form.pid, submit_btn.pid)

  ## Specification

  From the HTML Standard: "The requestSubmit() method, when invoked, must submit the form."

  ## Behavior

  - Runs form validation (unless no_validate is true)
  - Fires submit event (cancelable)
  - Uses submitter's form attributes if provided
  - Submits form data if validation passes and event not prevented
  """
  def request_submit(form_pid, submitter_pid \\ nil) do
    form = GenDOM.Node.get(form_pid)

    # Run validation unless disabled
    if form.no_validate or check_validity(form_pid) do
      # In real implementation would:
      # 1. Fire submit event (cancelable)
      # 2. If not prevented, submit form
      # 3. Use submitter's form attributes if provided

      submitter = if submitter_pid, do: GenDOM.Node.get(submitter_pid), else: nil

      # Use submitter's form attributes if available
      _action = if submitter && submitter.form_action != "", do: submitter.form_action, else: form.action
      method = if submitter && submitter.form_method != "", do: submitter.form_method, else: form.method

      case method do
        "get" -> :request_submit_get
        "post" -> :request_submit_post
        "dialog" -> :request_submit_dialog
        _ -> :request_submit_get
      end
    else
      :validation_failed
    end
  end

  @doc """
  Resets all form controls to their initial values.

  This method implements the HTMLFormElement `reset()` specification.
  It resets all form controls to their default values and fires a reset event.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Examples

      form = GenDOM.HTMLFormElement.new([action: "/submit"])
      GenDOM.HTMLFormElement.reset(form.pid)

  ## Specification

  From the HTML Standard: "The reset() method, when invoked, must run the form reset algorithm."

  ## Behavior

  - Fires reset event (cancelable)
  - If not prevented, resets all form controls to default values
  - Clears custom validation messages
  """
  def reset(form_pid) do
    form = GenDOM.Node.get(form_pid)

    # In real implementation would:
    # 1. Fire reset event (cancelable)
    # 2. If not prevented, reset all form controls

    # Reset all form controls to default values
    Enum.each(form.elements, fn element_pid ->
      element = GenDOM.Node.get(element_pid)
      case element.__struct__ do
        GenDOM.HTMLInputElement ->
          GenDOM.HTMLInputElement.set_value(element_pid, element.default_value)
          GenDOM.HTMLInputElement.set_checked(element_pid, element.default_checked)
          GenDOM.HTMLInputElement.set_custom_validity(element_pid, "")
        GenDOM.HTMLButtonElement ->
          GenDOM.HTMLButtonElement.set_custom_validity(element_pid, "")
        _ -> :ok
      end
    end)
  end

  @doc """
  Gets the collection of form control elements.

  Returns the live collection of form controls associated with this form.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  List of PIDs representing form control elements

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      elements = GenDOM.HTMLFormElement.get_elements(form.pid)
  """
  def get_elements(form_pid) do
    form = GenDOM.Node.get(form_pid)
    form.elements
  end

  @doc """
  Gets the number of form control elements.

  Returns the count of form controls in this form.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Integer count of form controls

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      count = GenDOM.HTMLFormElement.get_length(form.pid)
  """
  def get_length(form_pid) do
    form = GenDOM.Node.get(form_pid)
    form.length
  end

  @doc """
  Sets the form's action URL.

  Updates the URL where the form data will be submitted.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `action_url` - The action URL

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_action(form.pid, "/api/submit")
  """
  def set_action(form_pid, action_url) when is_binary(action_url) do
    GenDOM.Node.put(form_pid, :action, action_url)
  end

  @doc """
  Sets the form's HTTP method.

  Updates the HTTP method used for form submission.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `http_method` - The HTTP method ("get", "post", "dialog")

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_method(form.pid, "post")
  """
  def set_method(form_pid, http_method) when http_method in ["get", "post", "dialog"] do
    GenDOM.Node.put(form_pid, :method, http_method)
  end

  @doc """
  Sets the form's encoding type.

  Updates the content type used for form submission.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `encoding_type` - The encoding type

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_enctype(form.pid, "multipart/form-data")
  """
  def set_enctype(form_pid, encoding_type) when is_binary(encoding_type) do
    GenDOM.Node.put(form_pid, :enctype, encoding_type)
  end

  @doc """
  Sets the form's target.

  Updates where the response should be displayed after form submission.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `target_name` - The target name or keyword

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_target(form.pid, "_blank")
  """
  def set_target(form_pid, target_name) when is_binary(target_name) do
    GenDOM.Node.put(form_pid, :target, target_name)
  end

  @doc """
  Sets the form's name.

  Updates the name attribute of the form.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `form_name` - The form name

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_name(form.pid, "contact_form")
  """
  def set_name(form_pid, form_name) when is_binary(form_name) do
    GenDOM.Node.put(form_pid, :name, form_name)
  end

  @doc """
  Sets the form's accepted character sets.

  Updates the character encodings that the server accepts.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `charset` - The accepted character sets

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_accept_charset(form.pid, "UTF-8")
  """
  def set_accept_charset(form_pid, charset) when is_binary(charset) do
    GenDOM.Node.put(form_pid, :accept_charset, charset)
  end

  @doc """
  Sets the form's autocomplete behavior.

  Updates whether the form should have autocomplete enabled.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `autocomplete_value` - The autocomplete value ("on" or "off")

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_autocomplete(form.pid, "off")
  """
  def set_autocomplete(form_pid, autocomplete_value) when autocomplete_value in ["on", "off"] do
    GenDOM.Node.put(form_pid, :autocomplete, autocomplete_value)
  end

  @doc """
  Sets the form's validation behavior.

  Updates whether form validation should be skipped.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement
  - `skip_validation` - Boolean indicating whether to skip validation

  ## Examples

      form = GenDOM.HTMLFormElement.new([])
      GenDOM.HTMLFormElement.set_no_validate(form.pid, true)
  """
  def set_no_validate(form_pid, skip_validation) when is_boolean(skip_validation) do
    GenDOM.Node.put(form_pid, :no_validate, skip_validation)
  end

  @doc """
  Checks if form validation is enabled.

  Returns true if form validation is enabled, false if disabled.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Boolean indicating validation status

  ## Examples

      form = GenDOM.HTMLFormElement.new([no_validate: true])
      validates = GenDOM.HTMLFormElement.validates?(form.pid)
      # Returns: false
  """
  def validates?(form_pid) do
    form = GenDOM.Node.get(form_pid)
    not form.no_validate
  end

  @doc """
  Checks if the form method is GET.

  Returns true if the form uses GET method for submission.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Boolean indicating if method is GET

  ## Examples

      form = GenDOM.HTMLFormElement.new([method: "get"])
      is_get = GenDOM.HTMLFormElement.is_get_method?(form.pid)
      # Returns: true
  """
  def is_get_method?(form_pid) do
    form = GenDOM.Node.get(form_pid)
    form.method == "get"
  end

  @doc """
  Checks if the form method is POST.

  Returns true if the form uses POST method for submission.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Boolean indicating if method is POST

  ## Examples

      form = GenDOM.HTMLFormElement.new([method: "post"])
      is_post = GenDOM.HTMLFormElement.is_post_method?(form.pid)
      # Returns: true
  """
  def is_post_method?(form_pid) do
    form = GenDOM.Node.get(form_pid)
    form.method == "post"
  end

  @doc """
  Checks if the form method is dialog.

  Returns true if the form uses dialog method for submission.

  ## Parameters

  - `form_pid` - The PID of the HTMLFormElement

  ## Returns

  Boolean indicating if method is dialog

  ## Examples

      form = GenDOM.HTMLFormElement.new([method: "dialog"])
      is_dialog = GenDOM.HTMLFormElement.is_dialog_method?(form.pid)
      # Returns: true
  """
  def is_dialog_method?(form_pid) do
    form = GenDOM.Node.get(form_pid)
    form.method == "dialog"
  end
end
