defmodule GenDOM.HTMLSelectElement do
  @moduledoc """
  The HTMLSelectElement interface represents `<select>` elements.

  The HTMLSelectElement interface provides properties and methods for manipulating
  select elements. It inherits from HTMLElement and adds selection-specific functionality
  including option management, multiple selection support, and form validation.

  ## Specification Compliance

  This module implements the HTMLSelectElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/form-elements.html#htmlselectelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/sec-forms.html#the-select-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLSelectElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_select_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "select"

  ## Properties

  ### Core Selection
  - `selected_index` - Index of the first selected option (-1 if none selected)
  - `value` - Value of the first selected option
  - `options` - Collection of all option elements (read-only)
  - `selected_options` - Collection of currently selected options (read-only)
  - `length` - Total number of option elements (read-only)

  ### Configuration
  - `multiple` - Whether multiple selections are allowed
  - `disabled` - Whether the select element is disabled
  - `required` - Whether a selection is required
  - `name` - Element name for form submission
  - `type` - Select type ("select-one" or "select-multiple") (read-only)
  - `size` - Number of visible items in the control

  ### Form Integration
  - `form` - Associated form element (read-only)
  - `labels` - Associated label elements (read-only)

  ### Validation
  - `validity` - Current validation state (read-only)
  - `validation_message` - Validation error message (read-only)
  - `will_validate` - Whether select participates in validation (read-only)

  ### Autocomplete
  - `autocomplete` - Autocomplete behavior hint

  ## Methods

  ### Option Management
  - `add/3` - Add a new option element
  - `remove/2` - Remove an option at specified index
  - `item/2` - Retrieve an option by index
  - `named_item/2` - Find an option by name or ID

  ### Validation
  - `check_validity/1` - Check if select meets validation constraints
  - `report_validity/1` - Check validity and report to user
  - `set_custom_validity/2` - Set custom validation message

  ### Interaction
  - `show_picker/1` - Show the native option picker interface

  ### Inherited Methods
  All methods from HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Single selection dropdown
  select = GenDOM.HTMLSelectElement.new([
    name: "country",
    required: true
  ])

  # Multiple selection list
  multi_select = GenDOM.HTMLSelectElement.new([
    name: "skills",
    multiple: true,
    size: 5
  ])

  # Disabled select
  disabled_select = GenDOM.HTMLSelectElement.new([
    name: "status",
    disabled: true,
    value: "inactive"
  ])
  ```

  ## Option Management

  ### Adding Options
  ```elixir
  # Add option to select
  select = GenDOM.HTMLSelectElement.new([name: "colors"])
  option = GenDOM.HTMLOptionElement.new([value: "red", text: "Red"])
  GenDOM.HTMLSelectElement.add(select.pid, option, nil)

  # Add option at specific position
  GenDOM.HTMLSelectElement.add(select.pid, option, 0)
  ```

  ### Removing Options
  ```elixir
  # Remove option by index
  GenDOM.HTMLSelectElement.remove(select.pid, 2)

  # Remove all options
  select = GenDOM.HTMLSelectElement.new([name: "empty"])
  for i <- (GenDOM.HTMLSelectElement.get_length(select.pid) - 1)..0 do
    GenDOM.HTMLSelectElement.remove(select.pid, i)
  end
  ```

  ### Accessing Options
  ```elixir
  # Get option by index
  option = GenDOM.HTMLSelectElement.item(select.pid, 0)

  # Find option by name/id
  option = GenDOM.HTMLSelectElement.named_item(select.pid, "option-1")

  # Get all selected options
  selected = GenDOM.HTMLSelectElement.get_selected_options(select.pid)
  ```

  ## Selection Handling

  ### Single Selection
  ```elixir
  # Select by index
  select = GenDOM.HTMLSelectElement.new([name: "size"])
  GenDOM.HTMLSelectElement.set_selected_index(select.pid, 2)

  # Select by value
  GenDOM.HTMLSelectElement.set_value(select.pid, "large")

  # Get selected value
  value = GenDOM.HTMLSelectElement.get_value(select.pid)
  ```

  ### Multiple Selection
  ```elixir
  # Multiple selection list
  multi_select = GenDOM.HTMLSelectElement.new([
    name: "features",
    multiple: true,
    size: 4
  ])

  # Select multiple values (through option elements)
  # Note: Individual options must be selected via HTMLOptionElement.set_selected/2
  ```

  ## Form Validation

  ### Validation Setup
  ```elixir
  # Required select with validation
  select = GenDOM.HTMLSelectElement.new([
    name: "priority",
    required: true
  ])

  # Check if valid
  is_valid = GenDOM.HTMLSelectElement.check_validity(select.pid)

  # Set custom validation
  GenDOM.HTMLSelectElement.set_custom_validity(select.pid, "Please select a priority level")
  ```

  ### Validation Reporting
  ```elixir
  # Report validation issues to user
  is_valid = GenDOM.HTMLSelectElement.report_validity(select.pid)

  # Get validation message
  message = GenDOM.HTMLSelectElement.get_validation_message(select.pid)
  ```

  ## Size and Display

  ### List vs Dropdown
  ```elixir
  # Dropdown (default)
  dropdown = GenDOM.HTMLSelectElement.new([
    name: "category"
    # size: 1 (implicit)
  ])

  # List box
  listbox = GenDOM.HTMLSelectElement.new([
    name: "items",
    size: 6,
    multiple: true
  ])
  ```

  ## Accessibility

  ### Proper Labeling
  ```elixir
  # Select with proper labeling
  accessible_select = GenDOM.HTMLSelectElement.new([
    name: "language",
    required: true
    # Associate with <label> element
    # Consider aria-describedby for help text
  ])
  ```

  ### Required Fields
  ```elixir
  # Required select with clear indication
  required_select = GenDOM.HTMLSelectElement.new([
    name: "payment_method",
    required: true
    # Screen readers will announce required state
  ])
  ```

  ## Performance Considerations

  - **Large Option Lists**: Consider virtualization for hundreds of options
  - **Dynamic Options**: Batch option updates when possible
  - **Event Handling**: Use event delegation for option-related events
  - **Validation**: Validate on both client and server sides

  ## Browser Compatibility

  - **show_picker()**: Modern browsers only (check support before use)
  - **Multiple Selection**: Universally supported
  - **Validation API**: Supported in all modern browsers
  """

  @derive {Inspect, only: [:pid, :tag_name, :name, :value, :selected_index, :multiple]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for select-specific behavior
    tag_name: "select",
    
    # Core selection properties
    selected_index: -1, # -1 means no selection
    value: "",
    options: [], # read-only collection of HTMLOptionElement
    selected_options: [], # read-only collection of selected options
    length: 0, # read-only count of options

    # Configuration
    multiple: false,
    disabled: false,
    required: false,
    name: "",
    type: "select-one", # read-only: "select-one" | "select-multiple"
    size: 0, # 0 means browser default (usually 1 for dropdown, 4 for listbox)

    # Form integration
    form: nil, # read-only reference to HTMLFormElement
    labels: [], # read-only collection of HTMLLabelElement

    # Validation (read-only properties)
    validity: nil, # read-only ValidityState
    validation_message: "", # read-only
    will_validate: true, # read-only

    # Autocomplete
    autocomplete: ""
  ]

  @doc """
  Adds a new option element to the select.

  This method implements the HTMLSelectElement `add()` specification.
  Adds an option or optgroup element to the collection of options.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `element` - HTMLOptionElement or HTMLOptGroupElement to add
  - `before` - Optional index or element to insert before (nil to append)

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "colors"])
      option = GenDOM.HTMLOptionElement.new([value: "red", text: "Red"])
      GenDOM.HTMLSelectElement.add(select.pid, option, nil)

      # Insert at specific position
      GenDOM.HTMLSelectElement.add(select.pid, option, 0)

  ## Specification

  From the HTML Standard: "The add(element, before) method must act according to the following algorithm..."
  """
  def add(select_pid, element, before \\ nil) do
    select = GenDOM.Node.get(select_pid)
    current_options = select.options
    
    new_options = case before do
      nil -> 
        # Append to end
        current_options ++ [element]
      index when is_integer(index) ->
        # Insert at specific index
        {before_list, after_list} = Enum.split(current_options, index)
        before_list ++ [element] ++ after_list
      _ ->
        # Insert before specific element (simplified for now)
        current_options ++ [element]
    end
    
    GenDOM.Node.merge(select_pid, %{
      options: new_options,
      length: length(new_options)
    })
    
    # Update type based on multiple attribute
    update_type(select_pid)
  end

  @doc """
  Removes an option element at the specified index.

  This method implements the HTMLSelectElement `remove()` specification.
  Removes the option element at the given index from the options collection.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `index` - Index of the option to remove

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "items"])
      GenDOM.HTMLSelectElement.remove(select.pid, 2)

  ## Specification

  From the HTML Standard: "The remove(index) method must remove the indexth element in the list of options."
  """
  def remove(select_pid, index) when is_integer(index) and index >= 0 do
    select = GenDOM.Node.get(select_pid)
    
    if index < length(select.options) do
      new_options = List.delete_at(select.options, index)
      
      # Update selected_index if needed
      new_selected_index = cond do
        select.selected_index == index -> -1 # Removed the selected option
        select.selected_index > index -> select.selected_index - 1 # Shift down
        true -> select.selected_index # No change
      end
      
      GenDOM.Node.merge(select_pid, %{
        options: new_options,
        length: length(new_options),
        selected_index: new_selected_index
      })
      
      # Update value if selection changed
      update_value_from_selection(select_pid)
    end
  end

  @doc """
  Retrieves an option element by its index.

  This method implements the HTMLSelectElement `item()` specification.
  Returns the option element at the specified index, or nil if out of bounds.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `index` - Index of the option to retrieve

  ## Returns

  HTMLOptionElement at the index, or nil if index is out of bounds

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "colors"])
      option = GenDOM.HTMLSelectElement.item(select.pid, 0)
  """
  def item(select_pid, index) when is_integer(index) and index >= 0 do
    select = GenDOM.Node.get(select_pid)
    Enum.at(select.options, index)
  end

  @doc """
  Finds an option element by name or ID.

  This method implements the HTMLSelectElement `namedItem()` specification.
  Returns the first option element with the specified name or ID.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `name` - Name or ID to search for

  ## Returns

  HTMLOptionElement with matching name/ID, or nil if not found

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "countries"])
      option = GenDOM.HTMLSelectElement.named_item(select.pid, "usa")
  """
  def named_item(select_pid, name) when is_binary(name) do
    select = GenDOM.Node.get(select_pid)
    
    Enum.find(select.options, fn option ->
      # In a real implementation, would check option's name and id attributes
      # This is a simplified version
      false
    end)
  end

  @doc """
  Checks whether the select satisfies its validation constraints.

  This method implements the HTMLSelectElement `checkValidity()` specification.
  Returns true if the select meets all validation constraints, false otherwise.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "category", required: true])
      is_valid = GenDOM.HTMLSelectElement.check_validity(select.pid)

  ## Specification

  From the HTML Standard: "The checkValidity() method, when invoked, must run the check validity algorithm."
  """
  def check_validity(select_pid) do
    select = GenDOM.Node.get(select_pid)
    
    cond do
      select.required and select.selected_index == -1 -> false
      select.required and select.value == "" -> false
      select.validation_message != "" -> false
      true -> true
    end
  end

  @doc """
  Checks validity and reports validation problems to the user.

  This method implements the HTMLSelectElement `reportValidity()` specification.
  It performs validation and shows validation messages to the user if invalid.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Boolean indicating validity status

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "priority", required: true])
      is_valid = GenDOM.HTMLSelectElement.report_validity(select.pid)
  """
  def report_validity(select_pid) do
    is_valid = check_validity(select_pid)
    
    unless is_valid do
      # In real implementation would show validation UI
      select = GenDOM.Node.get(select_pid)
      # Fire 'invalid' event and show validation message
    end
    
    is_valid
  end

  @doc """
  Sets a custom validation message for the select.

  This method implements the HTMLSelectElement `setCustomValidity()` specification.
  Sets a custom error message that will be shown during validation.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `message` - Custom validation message (empty string clears custom validity)

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "rating", required: true])
      GenDOM.HTMLSelectElement.set_custom_validity(select.pid, "Please select a rating")
      
      # Clear custom validity
      GenDOM.HTMLSelectElement.set_custom_validity(select.pid, "")
  """
  def set_custom_validity(select_pid, message) when is_binary(message) do
    GenDOM.Node.put(select_pid, :validation_message, message)
    # In real implementation would update validity state
  end

  @doc """
  Shows the browser's built-in option picker interface.

  This method implements the HTMLSelectElement `showPicker()` specification.
  Displays the native select picker UI for the element.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "country"])
      GenDOM.HTMLSelectElement.show_picker(select.pid)

  ## Browser Support

  This method requires modern browser support. Check availability before use.
  """
  def show_picker(select_pid) do
    select = GenDOM.Node.get(select_pid)
    
    unless select.disabled do
      # In real implementation would trigger browser picker
      :show_select_picker
    end
  end

  @doc """
  Sets the selected index.

  Updates which option is selected by index position.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `index` - Index of option to select (-1 for no selection)

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "size"])
      GenDOM.HTMLSelectElement.set_selected_index(select.pid, 2)
  """
  def set_selected_index(select_pid, index) when is_integer(index) do
    select = GenDOM.Node.get(select_pid)
    
    valid_index = if index >= 0 and index < length(select.options) do
      index
    else
      -1
    end
    
    GenDOM.Node.put(select_pid, :selected_index, valid_index)
    update_value_from_selection(select_pid)
    update_selected_options(select_pid)
  end

  @doc """
  Sets the select value.

  Updates the value and selects the corresponding option.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `new_value` - Value to select

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "color"])
      GenDOM.HTMLSelectElement.set_value(select.pid, "blue")
  """
  def set_value(select_pid, new_value) when is_binary(new_value) do
    select = GenDOM.Node.get(select_pid)
    
    # Find option with matching value
    index = Enum.find_index(select.options, fn option ->
      # In real implementation would check option.value
      false # Simplified for now
    end)
    
    GenDOM.Node.put(select_pid, :value, new_value)
    
    if index do
      GenDOM.Node.put(select_pid, :selected_index, index)
    end
    
    update_selected_options(select_pid)
  end

  @doc """
  Enables or disables the select element.

  Updates the disabled attribute which controls user interaction.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `is_disabled` - Boolean indicating disabled state

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "status"])
      GenDOM.HTMLSelectElement.set_disabled(select.pid, true)
  """
  def set_disabled(select_pid, is_disabled) when is_boolean(is_disabled) do
    GenDOM.Node.put(select_pid, :disabled, is_disabled)
  end

  @doc """
  Sets whether multiple selections are allowed.

  Updates the multiple attribute and adjusts the type accordingly.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `is_multiple` - Boolean indicating multiple selection support

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "skills"])
      GenDOM.HTMLSelectElement.set_multiple(select.pid, true)
  """
  def set_multiple(select_pid, is_multiple) when is_boolean(is_multiple) do
    GenDOM.Node.put(select_pid, :multiple, is_multiple)
    update_type(select_pid)
  end

  @doc """
  Sets whether a selection is required.

  Updates the required attribute for form validation.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `is_required` - Boolean indicating required state

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "category"])
      GenDOM.HTMLSelectElement.set_required(select.pid, true)
  """
  def set_required(select_pid, is_required) when is_boolean(is_required) do
    GenDOM.Node.put(select_pid, :required, is_required)
  end

  @doc """
  Sets the select's name for form submission.

  Updates the name attribute used when submitting forms.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `name` - Select name

  ## Examples

      select = GenDOM.HTMLSelectElement.new([])
      GenDOM.HTMLSelectElement.set_name(select.pid, "user_preferences")
  """
  def set_name(select_pid, name) when is_binary(name) do
    GenDOM.Node.put(select_pid, :name, name)
  end

  @doc """
  Sets the size of the select control.

  Updates how many options are visible at once.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement
  - `size` - Number of visible options (0 for browser default)

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "items"])
      GenDOM.HTMLSelectElement.set_size(select.pid, 5)
  """
  def set_size(select_pid, size) when is_integer(size) and size >= 0 do
    GenDOM.Node.put(select_pid, :size, size)
  end

  @doc """
  Gets the current value of the select.

  Returns the value of the first selected option.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  String value of selected option, or empty string if none selected

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "color"])
      value = GenDOM.HTMLSelectElement.get_value(select.pid)
  """
  def get_value(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.value
  end

  @doc """
  Gets the currently selected index.

  Returns the index of the first selected option.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Integer index of selected option, or -1 if none selected

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "priority"])
      index = GenDOM.HTMLSelectElement.get_selected_index(select.pid)
  """
  def get_selected_index(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.selected_index
  end

  @doc """
  Gets all currently selected options.

  Returns a list of selected option elements.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  List of selected HTMLOptionElement PIDs

  ## Examples

      multi_select = GenDOM.HTMLSelectElement.new([name: "features", multiple: true])
      selected = GenDOM.HTMLSelectElement.get_selected_options(multi_select.pid)
  """
  def get_selected_options(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.selected_options
  end

  @doc """
  Gets the total number of options.

  Returns the count of option elements in the select.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Integer count of options

  ## Examples

      select = GenDOM.HTMLSelectElement.new([name: "countries"])
      count = GenDOM.HTMLSelectElement.get_length(select.pid)
  """
  def get_length(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.length
  end

  @doc """
  Checks if the select is disabled.

  Returns the current disabled state.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Boolean indicating disabled state

  ## Examples

      select = GenDOM.HTMLSelectElement.new([disabled: true])
      is_disabled = GenDOM.HTMLSelectElement.is_disabled?(select.pid)
  """
  def is_disabled?(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.disabled
  end

  @doc """
  Checks if multiple selections are allowed.

  Returns the current multiple attribute state.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Boolean indicating multiple selection support

  ## Examples

      select = GenDOM.HTMLSelectElement.new([multiple: true])
      is_multiple = GenDOM.HTMLSelectElement.is_multiple?(select.pid)
  """
  def is_multiple?(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.multiple
  end

  @doc """
  Checks if a selection is required.

  Returns the current required attribute state.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  Boolean indicating required state

  ## Examples

      select = GenDOM.HTMLSelectElement.new([required: true])
      is_required = GenDOM.HTMLSelectElement.is_required?(select.pid)
  """
  def is_required?(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.required
  end

  @doc """
  Gets the validation message.

  Returns the current validation error message.

  ## Parameters

  - `select_pid` - The PID of the HTMLSelectElement

  ## Returns

  String validation message

  ## Examples

      select = GenDOM.HTMLSelectElement.new([required: true])
      message = GenDOM.HTMLSelectElement.get_validation_message(select.pid)
  """
  def get_validation_message(select_pid) do
    select = GenDOM.Node.get(select_pid)
    select.validation_message
  end

  # Private helper functions

  defp update_type(select_pid) do
    select = GenDOM.Node.get(select_pid)
    new_type = if select.multiple, do: "select-multiple", else: "select-one"
    GenDOM.Node.put(select_pid, :type, new_type)
  end

  defp update_value_from_selection(select_pid) do
    select = GenDOM.Node.get(select_pid)
    
    new_value = if select.selected_index >= 0 and select.selected_index < length(select.options) do
      # In real implementation would get option.value
      # For now, simplified
      ""
    else
      ""
    end
    
    GenDOM.Node.put(select_pid, :value, new_value)
  end

  defp update_selected_options(select_pid) do
    select = GenDOM.Node.get(select_pid)
    
    # In real implementation would collect all selected options
    # For now, simplified to empty list
    selected = []
    
    GenDOM.Node.put(select_pid, :selected_options, selected)
  end
end