defmodule GenDom.HTMLElement do
  @moduledoc """
  HTMLElement represents any HTML element.

  The HTMLElement interface represents any HTML element. Some elements directly implement this interface,
  while others implement it via an interface that inherits it. It provides methods for user interaction
  and manages element-specific properties like focus, content editing, and drag-and-drop behavior.

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDom.HTMLElement (extends Element)
  ```

  **Inherits from:** `GenDOM.Element`
  **File:** `lib/gen_dom/html_element.ex`

  ## Properties

  ### Accessibility and Input
  - `access_key` - A string representing the access key assigned to the element
  - `access_key_label` - Returns a string containing the element's assigned access key (read-only)
  - `autofocus` - Indicates whether the control should be focused when the page loads
  - `tab_index` - Represents the element's position in the tabbing order

  ### Content and Text
  - `content_editable` - Indicates if the element is editable ("true", "false", or "inherit")
  - `inner_text` - Represents the rendered text content of a node and its descendants
  - `lang` - Represents the language of an element's attributes and contents
  - `title` - Contains text that appears in a popup when mouse hovers over the element

  ### Behavior and Interaction
  - `draggable` - Indicates if the element can be dragged
  - `hidden` - Reflects the hidden attribute's value
  - `autocapitalize` - Represents the element's capitalization behavior for user input
  - `dir` - Represents the directionality of the element ("ltr", "rtl", "auto")

  ### Data and Styling
  - `dataset` - Allows reading and writing custom data attributes (data-*)
  - `style` - Represents the element's inline style declarations

  ## Methods

  ### Focus Management
  - `focus/1` - Makes the element the current keyboard focus
  - `blur/1` - Removes keyboard focus from the currently focused element

  ### User Interaction
  - `click/1` - Sends a mouse click event to the element

  ### Form Integration
  - `attach_internals/1` - Enables a custom element to participate in HTML forms

  ### Popover API
  - `show_popover/1` - Shows a popover element
  - `hide_popover/1` - Hides a popover element
  - `toggle_popover/2` - Toggles a popover element between hidden and showing states

  ## Usage

  ```elixir
  # Create an HTMLElement
  html_element = GenDom.HTMLElement.new([
    tag_name: "div",
    content_editable: "true",
    draggable: true,
    access_key: "d"
  ])

  # Focus the element
  GenDom.HTMLElement.focus(html_element.pid)

  # Make it editable
  GenDom.HTMLElement.set_content_editable(html_element.pid, "true")
  ```

  ## Specification Compliance

  This module implements the HTMLElement interface as defined by the WHATWG HTML Standard:
  https://html.spec.whatwg.org/multipage/dom.html#htmlelement

  All properties and methods follow the Web API specifications for maximum compatibility
  with standard HTML element behavior.
  """

  @derive {Inspect, only: [:pid, :tag_name, :id, :class_list, :attributes]}

  use GenDOM.Element, [
    # HTMLElement-specific properties with default values
    access_key: "",
    access_key_label: "",
    autocapitalize: "",
    autofocus: false,
    content_editable: "inherit",
    dataset: %{},
    dir: "",
    draggable: false,
    hidden: false,
    inner_text: "",
    lang: "",
    style: %{},
    tab_index: -1,
    title: ""
  ]

  # HTMLElement instance method stubs

  @doc """
  Enables a custom element to participate in HTML forms.

  This method implements the HTMLElement `attachInternals()` specification. It returns an
  ElementInternals object that allows a custom element to participate in HTML forms and
  accessibility features. The element must be a custom element (tag name containing a hyphen).

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement to attach internals to

  ## Returns

  ElementInternals object that provides access to:
  - Form association and validation
  - Accessibility role and state management
  - Shadow DOM accessibility tree

  ## Examples

      internals = GenDom.HTMLElement.attach_internals(custom_element_pid)

  ## Specification

  From the HTML Standard: "The attachInternals() method, when invoked, must run the attach internals algorithm."

  ## Errors

  - Raises if called on a built-in element (not a custom element)
  - Raises if internals have already been attached to this element
  """
  def attach_internals(html_element_pid) do
    # Implementation stub
  end

  @doc """
  Removes keyboard focus from the currently focused element.

  This method implements the HTMLElement `blur()` specification. It removes keyboard focus
  from the element if it currently has focus. The blur event is fired before focus is removed.

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement to remove focus from

  ## Examples

      GenDom.HTMLElement.blur(input_element_pid)

  ## Specification

  From the HTML Standard: "The blur() method, when invoked, should run the unfocusing steps
  for the element on which the method was called."

  ## Events

  - Fires a 'blur' event on the element (if it had focus)
  - May fire 'focusout' event (bubbles)
  """
  def blur(html_element_pid) do
    # Implementation stub
  end

  @doc """
  Sends a mouse click event to the element.

  This method implements the HTMLElement `click()` specification. It simulates a mouse click
  on the element, firing the appropriate click events and triggering any default behaviors
  associated with clicking the element.

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement to click

  ## Examples

      GenDom.HTMLElement.click(button_element_pid)
      GenDom.HTMLElement.click(link_element_pid)

  ## Specification

  From the HTML Standard: "The click() method must run synthetic click activation steps
  on the element."

  ## Events

  Fires in sequence:
  1. 'mousedown' event
  2. 'mouseup' event  
  3. 'click' event
  4. Default action (if not prevented)

  ## Behavior

  - Respects the element's disabled state
  - Triggers form submission for submit buttons
  - Follows links for anchor elements
  - Activates form controls appropriately
  """
  def click(html_element_pid) do
    # Implementation stub
  end

  @doc """
  Makes the element the current keyboard focus.

  This method implements the HTMLElement `focus()` specification. It moves keyboard focus
  to the element, making it the active element for keyboard input. The element must be
  focusable for this to have any effect.

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement to focus

  ## Options

  Can be extended to accept focus options:
  - `preventScroll` - If true, prevents scrolling to the element

  ## Examples

      GenDom.HTMLElement.focus(input_element_pid)
      GenDom.HTMLElement.focus(button_element_pid)

  ## Specification

  From the HTML Standard: "The focus() method, when invoked, must run the focusing steps
  for the element on which the method was called."

  ## Events

  - Fires 'focus' event on the element (does not bubble)
  - May fire 'focusin' event (bubbles)

  ## Focusable Elements

  Elements that can receive focus include:
  - Form controls (input, select, textarea, button)
  - Links with href attribute
  - Elements with tabindex attribute
  - Audio/video elements with controls
  """
  def focus(html_element_pid) do
    # Implementation stub
  end

  @doc """
  Hides a popover element.

  This method implements the Popover API `hidePopover()` specification. It hides a popover
  element that is currently showing, firing appropriate events and updating the popover state.

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement with popover to hide

  ## Examples

      GenDom.HTMLElement.hide_popover(popover_element_pid)

  ## Specification

  From the Popover API specification: "The hidePopover() method steps are to run hide popover
  algorithm given this."

  ## Events

  - Fires 'beforetoggle' event (cancelable)
  - Fires 'toggle' event after hiding

  ## Errors

  - Raises if the element doesn't have a popover attribute
  - Raises if the popover is not currently showing
  """
  def hide_popover(html_element_pid) do
    # Implementation stub
  end

  @doc """
  Shows a popover element.

  This method implements the Popover API `showPopover()` specification. It shows a popover
  element, positioning it according to its popover behavior and firing appropriate events.

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement with popover to show

  ## Examples

      GenDom.HTMLElement.show_popover(popover_element_pid)

  ## Specification

  From the Popover API specification: "The showPopover() method steps are to run show popover
  algorithm given this."

  ## Events

  - Fires 'beforetoggle' event (cancelable)
  - Fires 'toggle' event after showing

  ## Popover Behavior

  - Auto popovers: Close when clicking outside or opening another auto popover
  - Manual popovers: Remain open until explicitly closed
  - Positions according to CSS anchor positioning if specified

  ## Errors

  - Raises if the element doesn't have a popover attribute
  - Raises if the popover is already showing
  """
  def show_popover(html_element_pid) do
    # Implementation stub
  end

  @doc """
  Toggles a popover element between hidden and showing states.

  This method implements the Popover API `togglePopover()` specification. It toggles the
  visibility state of a popover element, optionally forcing it to a specific state.

  ## Parameters

  - `html_element_pid` - The PID of the HTMLElement with popover to toggle
  - `force` - Optional boolean to force showing (true) or hiding (false)

  ## Returns

  Boolean indicating the new state: true if showing, false if hidden

  ## Examples

      # Toggle current state
      is_showing = GenDom.HTMLElement.toggle_popover(popover_element_pid)

      # Force show
      GenDom.HTMLElement.toggle_popover(popover_element_pid, true)

      # Force hide  
      GenDom.HTMLElement.toggle_popover(popover_element_pid, false)

  ## Specification

  From the Popover API specification: "The togglePopover(force) method steps are to run
  toggle popover algorithm given this and force."

  ## Events

  - Fires 'beforetoggle' event (cancelable)
  - Fires 'toggle' event after state change

  ## Errors

  - Raises if the element doesn't have a popover attribute
  """
  def toggle_popover(html_element_pid, force \\ nil) do
    # Implementation stub
  end
end
