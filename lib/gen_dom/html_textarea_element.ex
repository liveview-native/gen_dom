defmodule GenDOM.HTMLTextAreaElement do
  @moduledoc """
  The HTMLTextAreaElement interface represents `<textarea>` elements.

  The HTMLTextAreaElement interface provides properties and methods for manipulating
  textarea elements. It inherits from HTMLElement and adds text area-specific functionality
  including multi-line text editing, text selection, form validation, and display control.

  ## Specification Compliance

  This module implements the HTMLTextAreaElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/form-elements.html#htmltextareaelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/sec-forms.html#the-textarea-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLTextAreaElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_textarea_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "textarea"

  ## Properties

  ### Text Content and Value
  - `value` - Current text content of the textarea
  - `default_value` - Original/default text content
  - `text_length` - Length of the current text content (read-only)
  - `placeholder` - Placeholder text hint

  ### Display and Layout
  - `cols` - Visible width in average character widths
  - `rows` - Number of visible text lines
  - `wrap` - Text wrapping behavior ("soft", "hard", "off")

  ### Form Integration
  - `form` - Associated form element (read-only)
  - `name` - Element name for form submission
  - `labels` - Associated label elements (read-only)

  ### State and Interaction
  - `disabled` - Whether the textarea is disabled
  - `readonly` - Whether the textarea is read-only
  - `required` - Whether input is required for form submission
  - `autofocus` - Whether textarea should auto-focus on page load
  - `autocomplete` - Autocomplete behavior hint

  ### Text Selection
  - `selection_start` - Start position of current text selection
  - `selection_end` - End position of current text selection
  - `selection_direction` - Direction of text selection ("forward", "backward", "none")

  ### Validation
  - `validity` - Current validation state (read-only)
  - `validation_message` - Validation error message (read-only)
  - `will_validate` - Whether textarea participates in validation (read-only)
  - `min_length` - Minimum required text length
  - `max_length` - Maximum allowed text length

  ## Methods

  ### Text Selection and Manipulation
  - `select/1` - Select all text content
  - `set_selection_range/4` - Set text selection range
  - `set_range_text/4` - Replace text in specified range

  ### Validation
  - `check_validity/1` - Check if textarea meets validation constraints
  - `report_validity/1` - Check validity and report to user
  - `set_custom_validity/2` - Set custom validation message

  ### Inherited Methods
  All methods from HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Basic textarea
  textarea = GenDOM.HTMLTextAreaElement.new([
    name: "message",
    rows: 4,
    cols: 50,
    placeholder: "Enter your message here..."
  ])

  # Required textarea with validation
  required_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "feedback",
    required: true,
    min_length: 10,
    max_length: 500,
    rows: 6
  ])

  # Read-only textarea
  readonly_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "terms",
    readonly: true,
    rows: 10,
    cols: 80,
    value: "Terms and conditions text..."
  ])
  ```

  ## Text Content Management

  ### Setting and Getting Text
  ```elixir
  # Set textarea content
  textarea = GenDOM.HTMLTextAreaElement.new([name: "content"])
  GenDOM.HTMLTextAreaElement.set_value(textarea.pid, "Hello, World!")

  # Get current content
  content = GenDOM.HTMLTextAreaElement.get_value(textarea.pid)

  # Get text length
  length = GenDOM.HTMLTextAreaElement.get_text_length(textarea.pid)
  ```

  ### Default Values
  ```elixir
  # Textarea with default content
  textarea = GenDOM.HTMLTextAreaElement.new([
    name: "bio",
    default_value: "Tell us about yourself..."
  ])

  # Reset to default
  GenDOM.HTMLTextAreaElement.set_value(textarea.pid, 
    GenDOM.HTMLTextAreaElement.get_default_value(textarea.pid))
  ```

  ## Text Selection

  ### Selecting Text
  ```elixir
  # Select all text
  textarea = GenDOM.HTMLTextAreaElement.new([
    name: "editor",
    value: "The quick brown fox jumps over the lazy dog."
  ])
  GenDOM.HTMLTextAreaElement.select(textarea.pid)

  # Select specific range
  GenDOM.HTMLTextAreaElement.set_selection_range(textarea.pid, 4, 9, "forward")
  # Selects "quick"
  ```

  ### Text Manipulation
  ```elixir
  # Replace text in range
  textarea = GenDOM.HTMLTextAreaElement.new([
    name: "document",
    value: "Hello, World!"
  ])
  
  # Replace "World" with "Universe"
  GenDOM.HTMLTextAreaElement.set_range_text(textarea.pid, "Universe", 7, 12)
  # Result: "Hello, Universe!"

  # Insert text at cursor
  GenDOM.HTMLTextAreaElement.set_range_text(textarea.pid, " beautiful", 7, 7)
  # Result: "Hello, beautiful Universe!"
  ```

  ## Display Configuration

  ### Size and Layout
  ```elixir
  # Large text area
  large_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "article",
    rows: 20,
    cols: 80
  ])

  # Compact text area
  compact_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "comment",
    rows: 3,
    cols: 40
  ])

  # Update size dynamically
  GenDOM.HTMLTextAreaElement.set_rows(textarea.pid, 15)
  GenDOM.HTMLTextAreaElement.set_cols(textarea.pid, 60)
  ```

  ### Text Wrapping
  ```elixir
  # Soft wrap (default)
  soft_wrap = GenDOM.HTMLTextAreaElement.new([
    name: "message",
    wrap: "soft"  # Lines wrap visually but no line breaks in value
  ])

  # Hard wrap
  hard_wrap = GenDOM.HTMLTextAreaElement.new([
    name: "formatted",
    wrap: "hard",  # Line breaks included in submitted value
    cols: 50
  ])

  # No wrapping
  no_wrap = GenDOM.HTMLTextAreaElement.new([
    name: "code",
    wrap: "off"  # Text scrolls horizontally
  ])
  ```

  ## Form Validation

  ### Length Validation
  ```elixir
  # Textarea with length constraints
  validated_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "review",
    required: true,
    min_length: 50,
    max_length: 1000,
    placeholder: "Please write at least 50 characters..."
  ])

  # Check validity
  is_valid = GenDOM.HTMLTextAreaElement.check_validity(validated_textarea.pid)

  # Get validation details
  message = GenDOM.HTMLTextAreaElement.get_validation_message(validated_textarea.pid)
  ```

  ### Custom Validation
  ```elixir
  # Set custom validation message
  textarea = GenDOM.HTMLTextAreaElement.new([name: "feedback"])
  GenDOM.HTMLTextAreaElement.set_custom_validity(textarea.pid, 
    "Please provide constructive feedback")

  # Clear custom validation
  GenDOM.HTMLTextAreaElement.set_custom_validity(textarea.pid, "")

  # Report validation to user
  is_valid = GenDOM.HTMLTextAreaElement.report_validity(textarea.pid)
  ```

  ## State Management

  ### Enabled/Disabled State
  ```elixir
  # Disable textarea
  textarea = GenDOM.HTMLTextAreaElement.new([name: "status"])
  GenDOM.HTMLTextAreaElement.set_disabled(textarea.pid, true)

  # Check if disabled
  is_disabled = GenDOM.HTMLTextAreaElement.is_disabled?(textarea.pid)
  ```

  ### Read-Only State
  ```elixir
  # Make read-only
  textarea = GenDOM.HTMLTextAreaElement.new([name: "terms"])
  GenDOM.HTMLTextAreaElement.set_readonly(textarea.pid, true)

  # Check if read-only
  is_readonly = GenDOM.HTMLTextAreaElement.is_readonly?(textarea.pid)
  ```

  ## Accessibility

  ### Proper Labeling
  ```elixir
  # Accessible textarea with proper labeling
  accessible_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "description",
    required: true,
    placeholder: "Describe the issue in detail...",
    # Associate with <label> element
    # Consider aria-describedby for help text
    # Use aria-invalid for validation state
  ])
  ```

  ### Required Fields
  ```elixir
  # Required textarea with clear indication
  required_textarea = GenDOM.HTMLTextAreaElement.new([
    name: "message",
    required: true,
    # Screen readers will announce required state
    # Consider visual indicators for required fields
  ])
  ```

  ## Performance Considerations

  - **Large Text Content**: Consider virtual scrolling for very large documents
  - **Real-time Validation**: Debounce validation checks during typing
  - **Text Selection**: Cache selection positions for performance
  - **Auto-resize**: Implement efficient auto-resize algorithms

  ## Security Considerations

  - **XSS Prevention**: Always sanitize textarea content before rendering as HTML
  - **Content Length**: Enforce both client and server-side length limits
  - **Input Validation**: Validate content format and structure server-side
  """

  @derive {Inspect, only: [:pid, :tag_name, :name, :value, :rows, :cols, :disabled]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for textarea-specific behavior
    tag_name: "textarea",
    
    # Text content and value
    value: "",
    default_value: "",
    text_length: 0, # read-only
    placeholder: "",

    # Display and layout
    cols: 20, # visible width in average character widths
    rows: 2, # number of visible text lines
    wrap: "soft", # "soft" | "hard" | "off"

    # Form integration
    form: nil, # read-only reference to HTMLFormElement
    name: "",
    labels: [], # read-only collection of HTMLLabelElement

    # State and interaction
    disabled: false,
    readonly: false,
    required: false,
    autofocus: false,
    autocomplete: "",

    # Text selection
    selection_start: 0,
    selection_end: 0,
    selection_direction: "none", # "forward" | "backward" | "none"

    # Validation (read-only properties)
    validity: nil, # read-only ValidityState
    validation_message: "", # read-only
    will_validate: true, # read-only

    # Validation constraints
    min_length: nil, # minimum required text length
    max_length: nil  # maximum allowed text length
  ]

  @doc """
  Selects all text content in the textarea.

  This method implements the HTMLTextAreaElement `select()` specification.
  Selects the entire text content and places focus on the textarea.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([
        name: "content",
        value: "The quick brown fox"
      ])
      GenDOM.HTMLTextAreaElement.select(textarea.pid)

  ## Specification

  From the HTML Standard: "The select() method, when invoked, must run the text control selection algorithm."

  ## Events

  - Fires a 'select' event on the textarea
  - May fire 'selectionchange' event
  """
  def select(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    text_length = String.length(textarea.value)
    
    GenDOM.Node.merge(textarea_pid, %{
      selection_start: 0,
      selection_end: text_length,
      selection_direction: "forward"
    })
    
    # In real implementation would fire 'select' event and focus element
  end

  @doc """
  Sets the text selection range.

  This method implements the HTMLTextAreaElement `setSelectionRange()` specification.
  Selects a portion of the text content between the specified positions.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `start` - Start position of selection (0-based)
  - `end_pos` - End position of selection (0-based)
  - `direction` - Selection direction ("forward", "backward", "none")

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([
        name: "editor",
        value: "The quick brown fox jumps over the lazy dog."
      ])
      
      # Select "quick"
      GenDOM.HTMLTextAreaElement.set_selection_range(textarea.pid, 4, 9, "forward")

  ## Specification

  From the HTML Standard: "The setSelectionRange(start, end, direction) method must set the selection range."
  """
  def set_selection_range(textarea_pid, start, end_pos, direction \\ "none") 
      when is_integer(start) and is_integer(end_pos) and 
           direction in ["forward", "backward", "none"] do
    textarea = GenDOM.Node.get(textarea_pid)
    text_length = String.length(textarea.value)
    
    # Clamp values to valid range
    clamped_start = max(0, min(start, text_length))
    clamped_end = max(clamped_start, min(end_pos, text_length))
    
    GenDOM.Node.merge(textarea_pid, %{
      selection_start: clamped_start,
      selection_end: clamped_end,
      selection_direction: direction
    })
    
    # In real implementation would fire 'selectionchange' event
  end

  @doc """
  Replaces text in the specified range with new text.

  This method implements the HTMLTextAreaElement `setRangeText()` specification.
  Replaces the text between start and end positions with the provided replacement text.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `replacement` - Text to insert
  - `start` - Start position for replacement (optional, uses selection start)
  - `end_pos` - End position for replacement (optional, uses selection end)

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([
        name: "document",
        value: "Hello, World!"
      ])
      
      # Replace "World" with "Universe"
      GenDOM.HTMLTextAreaElement.set_range_text(textarea.pid, "Universe", 7, 12)
      # Result: "Hello, Universe!"

      # Insert text at current selection
      GenDOM.HTMLTextAreaElement.set_range_text(textarea.pid, " beautiful")

  ## Specification

  From the HTML Standard: "The setRangeText(replacement, start, end, selectionMode) method must run the text control set range text algorithm."
  """
  def set_range_text(textarea_pid, replacement, start \\ nil, end_pos \\ nil) 
      when is_binary(replacement) do
    textarea = GenDOM.Node.get(textarea_pid)
    
    # Use current selection if start/end not provided
    actual_start = start || textarea.selection_start
    actual_end = end_pos || textarea.selection_end
    
    # Perform text replacement
    {before, rest} = String.split_at(textarea.value, actual_start)
    {_replaced, after_text} = String.split_at(rest, actual_end - actual_start)
    
    new_value = before <> replacement <> after_text
    replacement_length = String.length(replacement)
    
    # Update selection to end of replacement
    new_selection_start = actual_start + replacement_length
    new_selection_end = new_selection_start
    
    GenDOM.Node.merge(textarea_pid, %{
      value: new_value,
      text_length: String.length(new_value),
      selection_start: new_selection_start,
      selection_end: new_selection_end,
      selection_direction: "none"
    })
    
    # In real implementation would fire 'input' and 'selectionchange' events
  end

  @doc """
  Checks whether the textarea satisfies its validation constraints.

  This method implements the HTMLTextAreaElement `checkValidity()` specification.
  Returns true if the textarea meets all validation constraints, false otherwise.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([
        name: "message",
        required: true,
        min_length: 10
      ])
      is_valid = GenDOM.HTMLTextAreaElement.check_validity(textarea.pid)

  ## Specification

  From the HTML Standard: "The checkValidity() method, when invoked, must run the check validity algorithm."
  """
  def check_validity(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    text_length = String.length(textarea.value)
    
    cond do
      textarea.required and textarea.value == "" -> false
      textarea.min_length and text_length < textarea.min_length -> false
      textarea.max_length and text_length > textarea.max_length -> false
      textarea.validation_message != "" -> false
      true -> true
    end
  end

  @doc """
  Checks validity and reports validation problems to the user.

  This method implements the HTMLTextAreaElement `reportValidity()` specification.
  It performs validation and shows validation messages to the user if invalid.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([
        name: "feedback",
        required: true,
        min_length: 50
      ])
      is_valid = GenDOM.HTMLTextAreaElement.report_validity(textarea.pid)
  """
  def report_validity(textarea_pid) do
    is_valid = check_validity(textarea_pid)
    
    unless is_valid do
      # In real implementation would show validation UI
      textarea = GenDOM.Node.get(textarea_pid)
      # Fire 'invalid' event and show validation message
    end
    
    is_valid
  end

  @doc """
  Sets a custom validation message for the textarea.

  This method implements the HTMLTextAreaElement `setCustomValidity()` specification.
  Sets a custom error message that will be shown during validation.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `message` - Custom validation message (empty string clears custom validity)

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "review"])
      GenDOM.HTMLTextAreaElement.set_custom_validity(textarea.pid, 
        "Please provide constructive feedback")
      
      # Clear custom validity
      GenDOM.HTMLTextAreaElement.set_custom_validity(textarea.pid, "")
  """
  def set_custom_validity(textarea_pid, message) when is_binary(message) do
    GenDOM.Node.put(textarea_pid, :validation_message, message)
    # In real implementation would update validity state
  end

  @doc """
  Sets the textarea value.

  Updates the text content of the textarea and recalculates text length.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `new_value` - New text content

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "content"])
      GenDOM.HTMLTextAreaElement.set_value(textarea.pid, "Hello, World!")
  """
  def set_value(textarea_pid, new_value) when is_binary(new_value) do
    GenDOM.Node.merge(textarea_pid, %{
      value: new_value,
      text_length: String.length(new_value)
    })
    
    # Reset selection to end of text
    text_length = String.length(new_value)
    GenDOM.Node.merge(textarea_pid, %{
      selection_start: text_length,
      selection_end: text_length,
      selection_direction: "none"
    })
  end

  @doc """
  Gets the current textarea value.

  Returns the text content of the textarea.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  String containing the textarea content

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "message"])
      content = GenDOM.HTMLTextAreaElement.get_value(textarea.pid)
  """
  def get_value(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.value
  end

  @doc """
  Gets the default value of the textarea.

  Returns the original default text content.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  String containing the default textarea content

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([default_value: "Default text"])
      default = GenDOM.HTMLTextAreaElement.get_default_value(textarea.pid)
  """
  def get_default_value(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.default_value
  end

  @doc """
  Gets the length of the current text content.

  Returns the character count of the textarea value.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Integer representing text length

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([value: "Hello"])
      length = GenDOM.HTMLTextAreaElement.get_text_length(textarea.pid)
      # Returns: 5
  """
  def get_text_length(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.text_length
  end

  @doc """
  Sets the number of visible rows.

  Updates the rows attribute controlling textarea height.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `rows` - Number of visible text lines

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "content"])
      GenDOM.HTMLTextAreaElement.set_rows(textarea.pid, 10)
  """
  def set_rows(textarea_pid, rows) when is_integer(rows) and rows > 0 do
    GenDOM.Node.put(textarea_pid, :rows, rows)
  end

  @doc """
  Sets the number of visible columns.

  Updates the cols attribute controlling textarea width.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `cols` - Width in average character widths

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "content"])
      GenDOM.HTMLTextAreaElement.set_cols(textarea.pid, 80)
  """
  def set_cols(textarea_pid, cols) when is_integer(cols) and cols > 0 do
    GenDOM.Node.put(textarea_pid, :cols, cols)
  end

  @doc """
  Sets the text wrapping behavior.

  Updates the wrap attribute controlling how text wraps.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `wrap_mode` - Wrapping mode ("soft", "hard", "off")

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "formatted"])
      GenDOM.HTMLTextAreaElement.set_wrap(textarea.pid, "hard")
  """
  def set_wrap(textarea_pid, wrap_mode) when wrap_mode in ["soft", "hard", "off"] do
    GenDOM.Node.put(textarea_pid, :wrap, wrap_mode)
  end

  @doc """
  Enables or disables the textarea.

  Updates the disabled attribute controlling user interaction.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `is_disabled` - Boolean indicating disabled state

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "content"])
      GenDOM.HTMLTextAreaElement.set_disabled(textarea.pid, true)
  """
  def set_disabled(textarea_pid, is_disabled) when is_boolean(is_disabled) do
    GenDOM.Node.put(textarea_pid, :disabled, is_disabled)
  end

  @doc """
  Sets the read-only state of the textarea.

  Updates the readonly attribute controlling editability.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `is_readonly` - Boolean indicating read-only state

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "terms"])
      GenDOM.HTMLTextAreaElement.set_readonly(textarea.pid, true)
  """
  def set_readonly(textarea_pid, is_readonly) when is_boolean(is_readonly) do
    GenDOM.Node.put(textarea_pid, :readonly, is_readonly)
  end

  @doc """
  Sets whether input is required.

  Updates the required attribute for form validation.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `is_required` - Boolean indicating required state

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "feedback"])
      GenDOM.HTMLTextAreaElement.set_required(textarea.pid, true)
  """
  def set_required(textarea_pid, is_required) when is_boolean(is_required) do
    GenDOM.Node.put(textarea_pid, :required, is_required)
  end

  @doc """
  Sets the textarea's name for form submission.

  Updates the name attribute used when submitting forms.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `name` - Textarea name

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([])
      GenDOM.HTMLTextAreaElement.set_name(textarea.pid, "user_message")
  """
  def set_name(textarea_pid, name) when is_binary(name) do
    GenDOM.Node.put(textarea_pid, :name, name)
  end

  @doc """
  Sets the placeholder text.

  Updates the placeholder attribute providing input hints.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `placeholder_text` - Placeholder hint text

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "message"])
      GenDOM.HTMLTextAreaElement.set_placeholder(textarea.pid, "Enter your message...")
  """
  def set_placeholder(textarea_pid, placeholder_text) when is_binary(placeholder_text) do
    GenDOM.Node.put(textarea_pid, :placeholder, placeholder_text)
  end

  @doc """
  Sets the minimum text length requirement.

  Updates the minlength attribute for validation.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `min_length` - Minimum required text length (nil to remove constraint)

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "review"])
      GenDOM.HTMLTextAreaElement.set_min_length(textarea.pid, 50)
  """
  def set_min_length(textarea_pid, min_length) when is_integer(min_length) or is_nil(min_length) do
    GenDOM.Node.put(textarea_pid, :min_length, min_length)
  end

  @doc """
  Sets the maximum text length limit.

  Updates the maxlength attribute for validation.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement
  - `max_length` - Maximum allowed text length (nil to remove constraint)

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([name: "comment"])
      GenDOM.HTMLTextAreaElement.set_max_length(textarea.pid, 500)
  """
  def set_max_length(textarea_pid, max_length) when is_integer(max_length) or is_nil(max_length) do
    GenDOM.Node.put(textarea_pid, :max_length, max_length)
  end

  @doc """
  Checks if the textarea is disabled.

  Returns the current disabled state.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Boolean indicating disabled state

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([disabled: true])
      is_disabled = GenDOM.HTMLTextAreaElement.is_disabled?(textarea.pid)
  """
  def is_disabled?(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.disabled
  end

  @doc """
  Checks if the textarea is read-only.

  Returns the current read-only state.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Boolean indicating read-only state

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([readonly: true])
      is_readonly = GenDOM.HTMLTextAreaElement.is_readonly?(textarea.pid)
  """
  def is_readonly?(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.readonly
  end

  @doc """
  Checks if input is required.

  Returns the current required state.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Boolean indicating required state

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([required: true])
      is_required = GenDOM.HTMLTextAreaElement.is_required?(textarea.pid)
  """
  def is_required?(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.required
  end

  @doc """
  Gets the current text selection start position.

  Returns the start index of the current text selection.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Integer position of selection start

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([value: "Hello World"])
      start = GenDOM.HTMLTextAreaElement.get_selection_start(textarea.pid)
  """
  def get_selection_start(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.selection_start
  end

  @doc """
  Gets the current text selection end position.

  Returns the end index of the current text selection.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Integer position of selection end

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([value: "Hello World"])
      end_pos = GenDOM.HTMLTextAreaElement.get_selection_end(textarea.pid)
  """
  def get_selection_end(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.selection_end
  end

  @doc """
  Gets the text selection direction.

  Returns the direction of the current text selection.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  String indicating selection direction ("forward", "backward", "none")

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([value: "Hello World"])
      direction = GenDOM.HTMLTextAreaElement.get_selection_direction(textarea.pid)
  """
  def get_selection_direction(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.selection_direction
  end

  @doc """
  Gets the validation message.

  Returns the current validation error message.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  String validation message

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([required: true])
      message = GenDOM.HTMLTextAreaElement.get_validation_message(textarea.pid)
  """
  def get_validation_message(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.validation_message
  end

  @doc """
  Gets the currently selected text.

  Returns the substring of the value between selection start and end.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  String containing the selected text

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([value: "Hello World"])
      GenDOM.HTMLTextAreaElement.set_selection_range(textarea.pid, 0, 5, "forward")
      selected = GenDOM.HTMLTextAreaElement.get_selected_text(textarea.pid)
      # Returns: "Hello"
  """
  def get_selected_text(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    start_pos = textarea.selection_start
    end_pos = textarea.selection_end
    
    if start_pos != end_pos do
      String.slice(textarea.value, start_pos, end_pos - start_pos)
    else
      ""
    end
  end

  @doc """
  Checks if text is currently selected.

  Returns true if there is an active text selection.

  ## Parameters

  - `textarea_pid` - The PID of the HTMLTextAreaElement

  ## Returns

  Boolean indicating if text is selected

  ## Examples

      textarea = GenDOM.HTMLTextAreaElement.new([value: "Hello World"])
      GenDOM.HTMLTextAreaElement.select(textarea.pid)
      has_selection = GenDOM.HTMLTextAreaElement.has_selection?(textarea.pid)
      # Returns: true
  """
  def has_selection?(textarea_pid) do
    textarea = GenDOM.Node.get(textarea_pid)
    textarea.selection_start != textarea.selection_end
  end
end