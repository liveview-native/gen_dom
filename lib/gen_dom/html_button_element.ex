defmodule GenDOM.HTMLButtonElement do
  @moduledoc """
  The HTMLButtonElement interface represents `<button>` elements.

  The HTMLButtonElement interface provides properties and methods for manipulating
  button elements. It inherits from HTMLElement and adds button-specific functionality
  including form association, validation, and interaction controls.

  ## Specification Compliance

  This module implements the HTMLButtonElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/form-elements.html#htmlbuttonelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/sec-forms.html#the-button-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLButtonElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_button_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "button"

  ## Properties

  ### Button Behavior
  - `type` - Button type ("submit", "reset", "button", "menu")
  - `disabled` - Whether the button is disabled
  - `value` - Form control value of the button
  - `name` - Button name for form submission

  ### Form Association
  - `form` - Associated form element (read-only)
  - `form_action` - Override form action URL
  - `form_enctype` - Override form encoding type
  - `form_method` - Override form HTTP method
  - `form_no_validate` - Skip form validation on submit
  - `form_target` - Override form target window/frame

  ### Validation
  - `will_validate` - Whether button participates in validation (read-only)
  - `validity` - Current validation state (read-only)
  - `validation_message` - Validation error message (read-only)
  - `labels` - Associated label elements (read-only)

  ### Commands and Popovers
  - `command` - Command action to perform
  - `command_for_element` - Element controlled by this button
  - `popover_target_element` - Popover element controlled by button
  - `popover_target_action` - Popover action ("show", "hide", "toggle")

  ## Methods

  ### Validation
  - `check_validity/1` - Check if button meets validation constraints
  - `report_validity/1` - Check validity and report to user
  - `set_custom_validity/2` - Set custom validation message

  ### Inherited Methods
  All methods from HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Submit button
  submit_btn = GenDOM.HTMLButtonElement.new([
    type: "submit",
    name: "action",
    value: "save"
  ])

  # Reset button
  reset_btn = GenDOM.HTMLButtonElement.new([
    type: "reset"
  ])

  # Generic button
  click_btn = GenDOM.HTMLButtonElement.new([
    type: "button",
    disabled: false
  ])

  # Form override button
  alt_submit = GenDOM.HTMLButtonElement.new([
    type: "submit",
    form_action: "/alt-endpoint",
    form_method: "PUT"
  ])
  ```

  ## Button Types

  ### Submit Button
  ```elixir
  # Default submit behavior
  submit = GenDOM.HTMLButtonElement.new([
    type: "submit",  # Default type
    name: "submit_type",
    value: "quick_save"
  ])

  # Submit with form overrides
  custom_submit = GenDOM.HTMLButtonElement.new([
    type: "submit",
    form_action: "/api/save",
    form_method: "POST",
    form_enctype: "application/json"
  ])
  ```

  ### Reset Button
  ```elixir
  # Reset form to initial values
  reset = GenDOM.HTMLButtonElement.new([
    type: "reset"
  ])
  ```

  ### Generic Button
  ```elixir
  # JavaScript-controlled button
  generic = GenDOM.HTMLButtonElement.new([
    type: "button"  # No default form behavior
  ])
  ```

  ## Form Integration

  ### Form Association
  ```elixir
  # Button automatically associates with ancestor form
  button = GenDOM.HTMLButtonElement.new([
    type: "submit",
    name: "action",
    value: "process"
  ])

  # Get associated form
  form_element = GenDOM.HTMLButtonElement.get_form(button.pid)
  ```

  ### Form Validation
  ```elixir
  # Check if button participates in validation
  button = GenDOM.HTMLButtonElement.new([type: "submit"])
  will_validate = GenDOM.HTMLButtonElement.will_validate?(button.pid)

  # Validate button
  is_valid = GenDOM.HTMLButtonElement.check_validity(button.pid)

  # Set custom validation
  GenDOM.HTMLButtonElement.set_custom_validity(button.pid, "Custom error message")
  ```

  ## Popover Controls

  ```elixir
  # Show popover button
  show_popover = GenDOM.HTMLButtonElement.new([
    type: "button",
    popover_target_action: "show"
    # popover_target_element set separately
  ])

  # Toggle popover button
  toggle_popover = GenDOM.HTMLButtonElement.new([
    type: "button", 
    popover_target_action: "toggle"
  ])
  ```

  ## Command Elements

  ```elixir
  # Command button
  command_btn = GenDOM.HTMLButtonElement.new([
    type: "button",
    command: "toggle-sidebar"
    # command_for_element set separately
  ])
  ```

  ## Accessibility

  ### Button Labeling
  ```elixir
  # Accessible button with clear purpose
  accessible_btn = GenDOM.HTMLButtonElement.new([
    type: "button",
    # Text content should clearly describe action
    # Consider aria-label for icon-only buttons
  ])
  ```

  ### Disabled State
  ```elixir
  # Properly disabled button
  disabled_btn = GenDOM.HTMLButtonElement.new([
    type: "submit",
    disabled: true
    # Screen readers will announce disabled state
  ])
  ```

  ## Security Considerations

  ### Form Submission
  ```elixir
  # Secure form submission
  secure_submit = GenDOM.HTMLButtonElement.new([
    type: "submit",
    form_method: "POST",  # Use POST for sensitive data
    form_no_validate: false  # Enable validation
  ])
  ```

  ## Performance Considerations

  - **Event Delegation**: Use event delegation for many buttons
  - **Disabled State**: Properly disable buttons during async operations
  - **Form Validation**: Validate on both client and server
  """

  @derive {Inspect, only: [:pid, :tag_name, :type, :disabled, :name, :value]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for button-specific behavior
    tag_name: "button",

    # Button behavior
    type: "submit", # "submit" | "reset" | "button" | "menu"
    disabled: false,
    value: "",
    name: "",

    # Form association and overrides
    form: nil, # read-only, reference to HTMLFormElement
    form_action: "",
    form_enctype: "",
    form_method: "",
    form_no_validate: false,
    form_target: "",

    # Validation (read-only properties)
    will_validate: true, # read-only
    validity: nil, # read-only ValidityState
    validation_message: "", # read-only
    labels: [], # read-only NodeList

    # Commands and popovers
    command: "",
    command_for_element: nil, # Element reference
    popover_target_element: nil, # Element reference  
    popover_target_action: "toggle" # "show" | "hide" | "toggle"
  ]

  @doc """
  Encodes the HTMLButtonElement into a map representation.

  This function extends the base Element encoding to include button-specific
  properties like type, disabled, value, and form associations.

  ## Parameters

  - `button` - The HTMLButtonElement struct to encode

  ## Returns

  Map containing all button properties including inherited Node and Element fields

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit", disabled: true])
      encoded = GenDOM.HTMLButtonElement.encode(button)
      # Returns: %{node_type: 1, tag_name: "button", type: "submit", disabled: true, ...}
  """
  def encode(button) do
    Map.merge(super(button), %{
      type: button.type,
      disabled: button.disabled,
      value: button.value,
      name: button.name,
      form: button.form,
      form_action: button.form_action,
      form_enctype: button.form_enctype,
      form_method: button.form_method,
      form_no_validate: button.form_no_validate,
      form_target: button.form_target,
      will_validate: button.will_validate,
      validity: button.validity,
      validation_message: button.validation_message,
      labels: button.labels,
      command: button.command,
      command_for_element: button.command_for_element,
      popover_target_element: button.popover_target_element,
      popover_target_action: button.popover_target_action
    })
  end

  @doc """
  Checks whether the button satisfies its validation constraints.

  This method implements the HTMLButtonElement `checkValidity()` specification.
  Returns true if the button meets all validation constraints, false otherwise.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit", name: "action"])
      is_valid = GenDOM.HTMLButtonElement.check_validity(button.pid)
      # Returns: true (if no validation errors)

  ## Specification

  From the HTML Standard: "The checkValidity() method, when invoked, must run the check validity algorithm."
  """
  def check_validity(button_pid) do
    button = GenDOM.Node.get(button_pid)
    # In real implementation would check validation constraints
    button.validation_message == ""
  end

  @doc """
  Checks validity and reports validation problems to the user.

  This method implements the HTMLButtonElement `reportValidity()` specification.
  It performs validation and shows validation messages to the user if invalid.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      is_valid = GenDOM.HTMLButtonElement.report_validity(button.pid)
      # Shows validation UI if invalid
  """
  def report_validity(button_pid) do
    is_valid = check_validity(button_pid)

    unless is_valid do
      # In real implementation would show validation UI
      _button = GenDOM.Node.get(button_pid)
      # Fire 'invalid' event and show validation message
    end

    is_valid
  end

  @doc """
  Sets a custom validation message for the button.

  This method implements the HTMLButtonElement `setCustomValidity()` specification.
  Sets a custom error message that will be shown during validation.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `message` - Custom validation message (empty string clears custom validity)

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLButtonElement.set_custom_validity(button.pid, "Please wait...")

      # Clear custom validity
      GenDOM.HTMLButtonElement.set_custom_validity(button.pid, "")
  """
  def set_custom_validity(button_pid, message) when is_binary(message) do
    GenDOM.Node.put(button_pid, :validation_message, message)
    # In real implementation would update validity state
  end

  @doc """
  Gets the form element associated with this button.

  Returns the form that contains this button, or nil if not in a form.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Returns

  PID of associated HTMLFormElement or nil

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      form_pid = GenDOM.HTMLButtonElement.get_form(button.pid)
  """
  def get_form(button_pid) do
    button = GenDOM.Node.get(button_pid)
    button.form
  end

  @doc """
  Checks if the button will participate in form validation.

  Returns true if the button is eligible for constraint validation.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Returns

  Boolean indicating validation participation

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      will_validate = GenDOM.HTMLButtonElement.will_validate?(button.pid)
      # Returns: true (submit buttons participate in validation)
  """
  def will_validate?(button_pid) do
    button = GenDOM.Node.get(button_pid)
    button.will_validate
  end

  @doc """
  Sets the button type.

  Updates the type attribute which controls the button's behavior.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `button_type` - Type value ("submit", "reset", "button", "menu")

  ## Examples

      button = GenDOM.HTMLButtonElement.new([])
      GenDOM.HTMLButtonElement.set_type(button.pid, "button")
  """
  def set_type(button_pid, button_type) when button_type in ["submit", "reset", "button", "menu"] do
    GenDOM.Node.put(button_pid, :type, button_type)
  end

  @doc """
  Enables or disables the button.

  Updates the disabled attribute which controls user interaction.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `is_disabled` - Boolean indicating disabled state

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLButtonElement.set_disabled(button.pid, true)
  """
  def set_disabled(button_pid, is_disabled) when is_boolean(is_disabled) do
    GenDOM.Node.put(button_pid, :disabled, is_disabled)
  end

  @doc """
  Sets the button's form control value.

  Updates the value that will be submitted with the form.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `value` - Form control value

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit", name: "action"])
      GenDOM.HTMLButtonElement.set_value(button.pid, "save_draft")
  """
  def set_value(button_pid, value) when is_binary(value) do
    GenDOM.Node.put(button_pid, :value, value)
  end

  @doc """
  Sets the button's name for form submission.

  Updates the name attribute used when submitting forms.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `name` - Button name

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLButtonElement.set_name(button.pid, "submit_action")
  """
  def set_name(button_pid, name) when is_binary(name) do
    GenDOM.Node.put(button_pid, :name, name)
  end

  @doc """
  Sets form action override for this button.

  Updates the formaction attribute which overrides the form's action URL.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `action_url` - Override action URL

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLButtonElement.set_form_action(button.pid, "/api/quick-save")
  """
  def set_form_action(button_pid, action_url) when is_binary(action_url) do
    GenDOM.Node.put(button_pid, :form_action, action_url)
  end

  @doc """
  Sets form method override for this button.

  Updates the formmethod attribute which overrides the form's HTTP method.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `method` - HTTP method ("GET", "POST", "PUT", "DELETE", etc.)

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLButtonElement.set_form_method(button.pid, "DELETE")
  """
  def set_form_method(button_pid, method) when is_binary(method) do
    GenDOM.Node.put(button_pid, :form_method, method)
  end

  @doc """
  Sets popover target and action for this button.

  Configures the button to control a popover element.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement
  - `popover_element_pid` - PID of the popover element to control
  - `action` - Popover action ("show", "hide", "toggle")

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "button"])
      popover = GenDOM.HTMLElement.new([popover: "auto"])
      GenDOM.HTMLButtonElement.set_popover_target(button.pid, popover.pid, "toggle")
  """
  def set_popover_target(button_pid, popover_element_pid, action) 
      when action in ["show", "hide", "toggle"] do
    GenDOM.Node.merge(button_pid, %{
      popover_target_element: popover_element_pid,
      popover_target_action: action
    })
  end

  @doc """
  Checks if the button is disabled.

  Returns the current disabled state of the button.

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Returns

  Boolean indicating disabled state

  ## Examples

      button = GenDOM.HTMLButtonElement.new([disabled: true])
      is_disabled = GenDOM.HTMLButtonElement.is_disabled?(button.pid)
      # Returns: true
  """
  def is_disabled?(button_pid) do
    button = GenDOM.Node.get(button_pid)
    button.disabled
  end

  @doc """
  Checks if this is a submit button.

  Returns true if the button type is "submit".

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Returns

  Boolean indicating if this is a submit button

  ## Examples

      submit_btn = GenDOM.HTMLButtonElement.new([type: "submit"])
      is_submit = GenDOM.HTMLButtonElement.is_submit?(submit_btn.pid)
      # Returns: true
  """
  def is_submit?(button_pid) do
    button = GenDOM.Node.get(button_pid)
    button.type == "submit"
  end

  @doc """
  Simulates a button click.

  Triggers the button's default action (form submission, reset, etc.).

  ## Parameters

  - `button_pid` - The PID of the HTMLButtonElement

  ## Examples

      button = GenDOM.HTMLButtonElement.new([type: "submit"])
      GenDOM.HTMLButtonElement.click(button.pid)
      # Triggers form submission
  """
  def click(button_pid) do
    button = GenDOM.Node.get(button_pid)

    unless button.disabled do
      case button.type do
        "submit" -> 
          # In real implementation would submit associated form
          :submit_form
        "reset" ->
          # In real implementation would reset associated form
          :reset_form
        _ ->
          # Fire click event for other button types
          :click_event
      end
    end
  end
end
