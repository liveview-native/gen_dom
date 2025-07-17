defmodule GenDOM.HTMLInputElement do
  @moduledoc """
  The HTMLInputElement interface represents `<input>` elements.

  The HTMLInputElement interface provides a large number of properties and methods for
  manipulating the layout and presentation of input elements. It supports all input
  types from text and email to file uploads and color pickers.

  ## Specification Compliance

  This module implements the HTMLInputElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/input.html#htmlinputelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/sec-forms.html#the-input-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLInputElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_input_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "input"

  ## Properties

  ### Core Input Properties
  - `type` - Input control type (text, email, password, etc.)
  - `name` - Element name for form submission
  - `value` - Current control value
  - `default_value` - Original/default value
  - `placeholder` - Placeholder text hint

  ### State and Interaction
  - `disabled` - Whether input is disabled
  - `readonly` - Whether input is read-only
  - `required` - Whether input is required
  - `autofocus` - Whether input should auto-focus
  - `autocomplete` - Autocomplete behavior hint

  ### Validation
  - `validity` - Current validation state (read-only)
  - `validation_message` - Validation error message (read-only)
  - `will_validate` - Whether input participates in validation (read-only)
  - `pattern` - Regular expression for validation
  - `min` - Minimum value for numeric/date inputs
  - `max` - Maximum value for numeric/date inputs
  - `min_length` - Minimum text length
  - `max_length` - Maximum text length
  - `step` - Step interval for numeric inputs

  ### Form Integration
  - `form` - Associated form element (read-only)
  - `form_action` - Override form action URL
  - `form_enctype` - Override form encoding type
  - `form_method` - Override form HTTP method
  - `form_no_validate` - Skip form validation
  - `form_target` - Override form target
  - `labels` - Associated label elements (read-only)

  ### Checkbox/Radio Properties
  - `checked` - Whether checkbox/radio is checked
  - `default_checked` - Default checked state
  - `indeterminate` - Indeterminate state for checkboxes

  ### File Input Properties
  - `files` - Selected files (read-only)
  - `accept` - Accepted file types
  - `multiple` - Whether multiple files allowed
  - `capture` - Media capture method

  ### Selection and Text
  - `selection_start` - Start of text selection
  - `selection_end` - End of text selection
  - `selection_direction` - Direction of text selection

  ### Specialized Input Properties
  - `alt` - Alternative text for image inputs
  - `src` - Source URL for image inputs
  - `width` - Width for image inputs
  - `height` - Height for image inputs
  - `size` - Visible character width
  - `list` - Associated datalist element

  ## Methods

  ### Validation
  - `check_validity/1` - Check validation constraints
  - `report_validity/1` - Check validity and report to user
  - `set_custom_validity/2` - Set custom validation message

  ### Selection and Text
  - `select/1` - Select all text content
  - `set_selection_range/4` - Set text selection range
  - `set_range_text/3` - Replace text in range

  ### Numeric Controls
  - `step_up/2` - Increment numeric value
  - `step_down/2` - Decrement numeric value

  ### File and Media
  - `show_picker/1` - Show file/date/color picker

  ## Input Types

  The HTMLInputElement supports numerous input types:

  ### Text Inputs
  - `text` - Single-line text input
  - `password` - Password input (masked)
  - `email` - Email address input
  - `tel` - Telephone number input
  - `url` - URL input
  - `search` - Search input

  ### Numeric Inputs  
  - `number` - Numeric input with spinner
  - `range` - Slider input

  ### Date/Time Inputs
  - `date` - Date picker
  - `time` - Time picker
  - `datetime-local` - Local date and time
  - `month` - Month picker
  - `week` - Week picker

  ### Choice Inputs
  - `checkbox` - Checkbox input
  - `radio` - Radio button input

  ### File/Media Inputs
  - `file` - File upload input
  - `image` - Image submit button

  ### Button Inputs
  - `submit` - Form submit button
  - `reset` - Form reset button
  - `button` - Generic button

  ### Other Inputs
  - `hidden` - Hidden input
  - `color` - Color picker

  ## Usage Examples

  ```elixir
  # Text input
  text_input = GenDOM.HTMLInputElement.new([
    type: "text",
    name: "username",
    placeholder: "Enter username",
    required: true,
    max_length: 50
  ])

  # Email input with validation
  email_input = GenDOM.HTMLInputElement.new([
    type: "email",
    name: "email",
    placeholder: "user@example.com",
    required: true
  ])

  # Number input with range
  number_input = GenDOM.HTMLInputElement.new([
    type: "number",
    name: "age",
    min: "18",
    max: "120",
    step: "1",
    value: "25"
  ])

  # File input
  file_input = GenDOM.HTMLInputElement.new([
    type: "file",
    name: "upload",
    accept: "image/*",
    multiple: true
  ])

  # Checkbox
  checkbox = GenDOM.HTMLInputElement.new([
    type: "checkbox",
    name: "agree",
    value: "yes",
    checked: false
  ])
  ```

  ## Form Validation

  ```elixir
  # Text input with pattern validation
  validated_input = GenDOM.HTMLInputElement.new([
    type: "text",
    name: "phone",
    pattern: "\\d{3}-\\d{3}-\\d{4}",
    placeholder: "123-456-7890",
    title: "Please enter phone as XXX-XXX-XXXX"
  ])

  # Check validity
  is_valid = GenDOM.HTMLInputElement.check_validity(validated_input.pid)

  # Set custom validation
  GenDOM.HTMLInputElement.set_custom_validity(validated_input.pid, "Custom error")
  ```

  ## Text Selection

  ```elixir
  # Select all text
  text_input = GenDOM.HTMLInputElement.new([type: "text", value: "Hello World"])
  GenDOM.HTMLInputElement.select(text_input.pid)

  # Set selection range
  GenDOM.HTMLInputElement.set_selection_range(text_input.pid, 0, 5, "forward")
  ```

  ## File Handling

  ```elixir
  # File input configuration
  file_input = GenDOM.HTMLInputElement.new([
    type: "file",
    accept: ".jpg,.png,.gif",
    multiple: true,
    capture: "camera"  # For mobile camera capture
  ])

  # Show file picker
  GenDOM.HTMLInputElement.show_picker(file_input.pid)
  ```

  ## Accessibility

  Always ensure inputs are properly labeled and accessible:

  ```elixir
  # Accessible input with proper labeling
  accessible_input = GenDOM.HTMLInputElement.new([
    type: "email",
    name: "email",
    required: true,
    # Associate with label element
    # aria-describedby for help text
  ])
  ```
  """

  @derive {Inspect, only: [:pid, :tag_name, :type, :name, :value, :checked]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for input-specific behavior
    tag_name: "input",
    
    # Core properties
    type: "text",
    name: "",
    value: "",
    default_value: "",
    placeholder: "",

    # State and interaction
    disabled: false,
    readonly: false,
    required: false,
    autofocus: false,
    autocomplete: "",

    # Validation (read-only properties set by browser)
    validity: nil, # ValidityState object
    validation_message: "",
    will_validate: true,
    
    # Validation constraints
    pattern: "",
    min: "",
    max: "",
    min_length: nil,
    max_length: nil,
    step: "",

    # Form integration
    form: nil, # read-only reference
    form_action: "",
    form_enctype: "",
    form_method: "",
    form_no_validate: false,
    form_target: "",
    labels: [], # read-only list

    # Checkbox/radio properties
    checked: false,
    default_checked: false,
    indeterminate: false,

    # File input properties
    files: [], # read-only FileList
    accept: "",
    multiple: false,
    capture: "",

    # Selection properties
    selection_start: nil,
    selection_end: nil,
    selection_direction: "none", # "forward" | "backward" | "none"

    # Specialized properties
    alt: "", # for image inputs
    src: "", # for image inputs
    width: nil, # for image inputs
    height: nil, # for image inputs
    size: nil, # visible width in characters
    list: nil # reference to datalist element
  ]

  @doc """
  Encodes the HTMLInputElement into a map representation.

  This function extends the base Element encoding to include input-specific
  properties like type, value, validation attributes, and form associations.

  ## Parameters

  - `input` - The HTMLInputElement struct to encode

  ## Returns

  Map containing all input properties including inherited Node and Element fields

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "email", required: true])
      encoded = GenDOM.HTMLInputElement.encode(input)
      # Returns: %{node_type: 1, tag_name: "input", type: "email", required: true, ...}
  """
  def encode(input) do
    Map.merge(super(input), %{
      type: input.type,
      name: input.name,
      value: input.value,
      default_value: input.default_value,
      placeholder: input.placeholder,
      disabled: input.disabled,
      readonly: input.readonly,
      required: input.required,
      autofocus: input.autofocus,
      autocomplete: input.autocomplete,
      validity: input.validity,
      validation_message: input.validation_message,
      will_validate: input.will_validate,
      pattern: input.pattern,
      min: input.min,
      max: input.max,
      min_length: input.min_length,
      max_length: input.max_length,
      step: input.step,
      form: input.form,
      form_action: input.form_action,
      form_enctype: input.form_enctype,
      form_method: input.form_method,
      form_no_validate: input.form_no_validate,
      form_target: input.form_target,
      labels: input.labels,
      checked: input.checked,
      default_checked: input.default_checked,
      indeterminate: input.indeterminate,
      files: input.files,
      accept: input.accept,
      multiple: input.multiple,
      capture: input.capture,
      selection_start: input.selection_start,
      selection_end: input.selection_end,
      selection_direction: input.selection_direction,
      alt: input.alt,
      src: input.src,
      width: input.width,
      height: input.height,
      size: input.size,
      list: input.list
    })
  end

  @doc """
  Checks whether the input satisfies its validation constraints.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "email", value: "invalid-email"])
      is_valid = GenDOM.HTMLInputElement.check_validity(input.pid)
      # Returns: false (invalid email format)
  """
  def check_validity(input_pid) do
    input = GenDOM.Node.get(input_pid)
    
    # Basic validation checks
    cond do
      input.required and input.value == "" -> false
      input.pattern != "" and not Regex.match?(~r/#{input.pattern}/, input.value) -> false
      input.type == "email" and not valid_email?(input.value) -> false
      input.min_length and String.length(input.value) < input.min_length -> false
      input.max_length and String.length(input.value) > input.max_length -> false
      input.validation_message != "" -> false
      true -> true
    end
  end

  @doc """
  Checks validity and reports validation problems to the user.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement

  ## Returns

  Boolean indicating validity status
  """
  def report_validity(input_pid) do
    is_valid = check_validity(input_pid)
    
    unless is_valid do
      # In real implementation would show validation UI
      input = GenDOM.Node.get(input_pid)
      # Fire 'invalid' event and show validation message
    end
    
    is_valid
  end

  @doc """
  Sets a custom validation message.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `message` - Custom validation message

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "text"])
      GenDOM.HTMLInputElement.set_custom_validity(input.pid, "This field is required")
  """
  def set_custom_validity(input_pid, message) when is_binary(message) do
    GenDOM.Node.put(input_pid, :validation_message, message)
  end

  @doc """
  Selects all text in the input.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "text", value: "Hello World"])
      GenDOM.HTMLInputElement.select(input.pid)
  """
  def select(input_pid) do
    input = GenDOM.Node.get(input_pid)
    text_length = String.length(input.value)
    
    GenDOM.Node.merge(input_pid, %{
      selection_start: 0,
      selection_end: text_length,
      selection_direction: "forward"
    })
  end

  @doc """
  Sets the text selection range.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `start` - Start position of selection
  - `end_pos` - End position of selection  
  - `direction` - Selection direction ("forward", "backward", "none")

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "text", value: "Hello World"])
      GenDOM.HTMLInputElement.set_selection_range(input.pid, 0, 5, "forward")
  """
  def set_selection_range(input_pid, start, end_pos, direction \\ "none") 
      when is_integer(start) and is_integer(end_pos) and direction in ["forward", "backward", "none"] do
    GenDOM.Node.merge(input_pid, %{
      selection_start: start,
      selection_end: end_pos,
      selection_direction: direction
    })
  end

  @doc """
  Increments the numeric value.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `n` - Number of steps to increment (default: 1)

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "number", value: "5", step: "2"])
      GenDOM.HTMLInputElement.step_up(input.pid, 3)  # Value becomes "11"
  """
  def step_up(input_pid, n \\ 1) when is_integer(n) do
    input = GenDOM.Node.get(input_pid)
    
    if input.type in ["number", "range", "date", "time", "datetime-local", "month", "week"] do
      current_value = parse_numeric_value(input.value, input.type)
      step_size = parse_step(input.step, input.type)
      new_value = current_value + (step_size * n)
      
      # Apply max constraint
      final_value = if input.max != "" do
        max_val = parse_numeric_value(input.max, input.type)
        min(new_value, max_val)
      else
        new_value
      end
      
      formatted_value = format_numeric_value(final_value, input.type)
      GenDOM.Node.put(input_pid, :value, formatted_value)
    end
  end

  @doc """
  Decrements the numeric value.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `n` - Number of steps to decrement (default: 1)

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "number", value: "10", step: "2"])
      GenDOM.HTMLInputElement.step_down(input.pid, 2)  # Value becomes "6"
  """
  def step_down(input_pid, n \\ 1) when is_integer(n) do
    step_up(input_pid, -n)
  end

  @doc """
  Shows the browser's built-in picker for the input.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement

  ## Examples

      file_input = GenDOM.HTMLInputElement.new([type: "file"])
      GenDOM.HTMLInputElement.show_picker(file_input.pid)
  """
  def show_picker(input_pid) do
    input = GenDOM.Node.get(input_pid)
    
    # In real implementation would trigger browser picker
    case input.type do
      "file" -> :show_file_picker
      "date" -> :show_date_picker  
      "time" -> :show_time_picker
      "color" -> :show_color_picker
      _ -> :no_picker_available
    end
  end

  @doc """
  Sets the input value.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `new_value` - New value for the input

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "text"])
      GenDOM.HTMLInputElement.set_value(input.pid, "Hello World")
  """
  def set_value(input_pid, new_value) when is_binary(new_value) do
    GenDOM.Node.put(input_pid, :value, new_value)
  end

  @doc """
  Sets the checked state for checkbox/radio inputs.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `is_checked` - Boolean checked state

  ## Examples

      checkbox = GenDOM.HTMLInputElement.new([type: "checkbox"])
      GenDOM.HTMLInputElement.set_checked(checkbox.pid, true)
  """
  def set_checked(input_pid, is_checked) when is_boolean(is_checked) do
    GenDOM.Node.put(input_pid, :checked, is_checked)
  end

  @doc """
  Sets the input type.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement
  - `input_type` - New input type

  ## Examples

      input = GenDOM.HTMLInputElement.new([type: "text"])
      GenDOM.HTMLInputElement.set_type(input.pid, "email")
  """
  def set_type(input_pid, input_type) when is_binary(input_type) do
    GenDOM.Node.put(input_pid, :type, input_type)
  end

  @doc """
  Checks if the input is a checkbox or radio button.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement

  ## Returns

  Boolean indicating if input is checkable

  ## Examples

      checkbox = GenDOM.HTMLInputElement.new([type: "checkbox"])
      is_checkable = GenDOM.HTMLInputElement.is_checkable?(checkbox.pid)
      # Returns: true
  """
  def is_checkable?(input_pid) do
    input = GenDOM.Node.get(input_pid)
    input.type in ["checkbox", "radio"]
  end

  @doc """
  Checks if the input accepts file uploads.

  ## Parameters

  - `input_pid` - The PID of the HTMLInputElement

  ## Returns

  Boolean indicating if input accepts files

  ## Examples

      file_input = GenDOM.HTMLInputElement.new([type: "file"])
      accepts_files = GenDOM.HTMLInputElement.accepts_files?(file_input.pid)
      # Returns: true
  """
  def accepts_files?(input_pid) do
    input = GenDOM.Node.get(input_pid)
    input.type == "file"
  end

  # Private helper functions

  defp valid_email?(email) do
    # Simple email validation regex
    Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email)
  end

  defp parse_numeric_value(value, type) do
    case type do
      "number" -> String.to_float(value)
      "range" -> String.to_float(value)
      _ -> String.to_integer(value)
    end
  rescue
    _ -> 0
  end

  defp parse_step(step, _type) do
    case step do
      "" -> 1
      "any" -> 1
      _ -> String.to_float(step)
    end
  rescue
    _ -> 1
  end

  defp format_numeric_value(value, type) do
    case type do
      t when t in ["number", "range"] -> 
        if value == trunc(value), do: to_string(trunc(value)), else: to_string(value)
      _ -> 
        to_string(trunc(value))
    end
  end
end
