# GenDOM 🌳

A powerful Elixir library for creating, manipulating, and querying DOM structures with a comprehensive implementation of the DOM specification.

## ✨ Features

- 🏗️ **Complete DOM Implementation** - Full Node, Element, Document, and specialized element support
- 🔗 **Proper Inheritance Chain** - Node → Element → Form/Button/Input with field and method inheritance
- 🎯 **CSS Selector Support** - Query elements using standard CSS selectors
- 📄 **Template Parsing** - Parse templates and convert them to DOM structures
- 🔍 **Element Querying** - Find elements by ID, class, tag name, and complex selectors
- 🧬 **Process-Based Nodes** - Each DOM node runs as a GenServer for state management
- 📚 **Comprehensive Documentation** - All methods documented with examples
- ⚡ **High Performance** - Optimized for large DOM trees and complex operations

## 📦 Installation

Add `gen_dom` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_dom, "~> 0.1.0"}
  ]
end
```

## 🚀 Quick Start

### Creating a Basic DOM Structure

```elixir
# Create a document
{:ok, document} = GenDOM.Document.new()

# Create elements
{:ok, html_element} = GenDOM.Element.new(tag_name: "html")
{:ok, body_element} = GenDOM.Element.new(tag_name: "body", class_list: ["main-content"])
{:ok, div_element} = GenDOM.Element.new(
  tag_name: "div",
  id: "container",
  attributes: %{"data-role" => "main"}
)

# Build the structure
document = GenDOM.Document.append_child(document, html_element)
html_element = GenDOM.Element.append_child(html_element, body_element)
body_element = GenDOM.Element.append_child(body_element, div_element)
```

### Working with Form Elements 📋

```elixir
# Create a form with FormElement interface
{:ok, form} = GenDOM.Element.Form.new(
  tag_name: "form",
  action: "/submit",
  method: "post",
  autocomplete: "on"
)

# Add form controls
{:ok, input} = GenDOM.Element.Input.new(
  tag_name: "input",
  type: "email",
  name: "email",
  placeholder: "Enter your email",
  required: true
)

{:ok, button} = GenDOM.Element.Button.new(
  tag_name: "button",
  type: "submit",
  value: "Submit Form"
)

# Assemble the form
form = GenDOM.Element.Form.append_child(form, input)
form = GenDOM.Element.Form.append_child(form, button)

# Use FormElement methods
is_valid = GenDOM.Element.Form.check_validity(form)
GenDOM.Element.Form.submit(form)
```

### Parsing from Templates 📄

```elixir
# Parse from string
html_string = """
<div class="container">
  <h1 id="title">Welcome</h1>
  <p class="description">This is a sample page</p>
  <button type="button" onclick="alert('Hello!')">Click me</button>
</div>
"""

{:ok, document} = GenDOM.Parser.parse_from_html(html_string)
```

### CSS Selector Querying 🔍

```elixir
# Query by ID
title_element = GenDOM.Document.get_element_by_id(document, "title")

# Query by class name
descriptions = GenDOM.Document.get_elements_by_class_name(document, ["description"])

# Query by tag name
all_buttons = GenDOM.Document.get_elements_by_tag_name(document, "button")

# Complex CSS selectors
# Find all buttons inside containers
buttons_in_containers = GenDOM.Document.query_selector_all(document, ".container button")

# Find first paragraph with specific class
first_desc = GenDOM.Document.query_selector(document, "p.description")

# Advanced selectors
form_inputs = GenDOM.Document.query_selector_all(document, "form input[type='email']")
```

### Element Manipulation 🔧

```elixir
# Get and set attributes
class_value = GenDOM.Element.get_attribute(div_element, "class")
updated_div = GenDOM.Element.set_attribute(div_element, "data-loaded", "true")

# Work with classes
updated_div = GenDOM.Element.add_class(updated_div, "active")
has_class = GenDOM.Element.has_class?(updated_div, "container")

# Check element relationships
is_descendant = GenDOM.Node.contains?(body_element, div_element)
parent = GenDOM.Node.get_parent_node(div_element)

# Clone elements
cloned_div = GenDOM.Node.clone_node(div_element, true) # deep clone
shallow_clone = GenDOM.Node.clone_node(div_element, false)
```

### Advanced DOM Operations ⚡

```elixir
# Insert elements at specific positions
{:ok, new_paragraph} = GenDOM.Element.new(
  tag_name: "p", 
  text_content: "Inserted paragraph"
)

# Insert before existing element
updated_body = GenDOM.Node.insert_before(body_element, new_paragraph, div_element)

# Replace existing elements
{:ok, replacement} = GenDOM.Element.new(tag_name: "section", class_list: ["new-section"])
updated_body = GenDOM.Node.replace_child(body_element, replacement, div_element)

# Remove elements
updated_body = GenDOM.Node.remove_child(body_element, div_element)
```

### Working with Text Content ✏️

```elixir
# Create text nodes
{:ok, text_node} = GenDOM.Text.new(data: "Hello, World!")

# Set text content on elements
updated_element = GenDOM.Element.set_text_content(div_element, "New content")

# Get text content
content = GenDOM.Element.get_text_content(div_element)
```

### Form Validation and Submission ✅

```elixir
# Create a complex form
{:ok, contact_form} = GenDOM.Element.Form.new(
  tag_name: "form",
  action: "/contact",
  method: "post",
  no_validate: false
)

# Add various input types
{:ok, name_input} = GenDOM.Element.Input.new(
  tag_name: "input",
  type: "text",
  name: "name",
  required: true,
  minlength: 2,
  maxlength: 50
)

{:ok, email_input} = GenDOM.Element.Input.new(
  tag_name: "input",
  type: "email",
  name: "email",
  required: true,
  pattern: ".*@.*\\..*"
)

{:ok, age_input} = GenDOM.Element.Input.new(
  tag_name: "input",
  type: "number",
  name: "age",
  min: 18,
  max: 120,
  step: 1
)

# Assemble form
contact_form = GenDOM.Element.Form.append_child(contact_form, name_input)
contact_form = GenDOM.Element.Form.append_child(contact_form, email_input)
contact_form = GenDOM.Element.Form.append_child(contact_form, age_input)

# Validate form
is_valid = GenDOM.Element.Form.check_validity(contact_form)
validation_report = GenDOM.Element.Form.report_validity(contact_form)

# Submit form
GenDOM.Element.Form.request_submit(contact_form)
```

### Element Traversal and Navigation 🔄

```elixir
# Navigate the DOM tree
first_child = GenDOM.Node.get_first_child(body_element)
last_child = GenDOM.Node.get_last_child(body_element)
next_sibling = GenDOM.Node.get_next_sibling(div_element)
previous_sibling = GenDOM.Node.get_previous_sibling(div_element)

# Check node relationships
has_children = GenDOM.Node.has_child_nodes?(body_element)
is_same = GenDOM.Node.is_same_node?(div_element, div_element)
is_equal = GenDOM.Node.is_equal_node?(div_element, cloned_div)

# Find closest ancestor matching selector
closest_container = GenDOM.Element.closest(some_element, ".container")

# Get all children matching criteria
child_paragraphs = GenDOM.Element.get_elements_by_tag_name(body_element, "p")
```

### Element Geometry and Positioning 📏

```elixir
# Get element dimensions and position
bounding_rect = GenDOM.Element.get_bounding_client_rect(div_element)
client_rects = GenDOM.Element.get_client_rects(div_element)

# Scroll operations
GenDOM.Element.scroll_into_view(div_element, true)
GenDOM.Element.scroll_to(container_element, 0, 100)
GenDOM.Element.scroll_by(container_element, top: 50, left: 0)
```

### Event Handling Preparation ⚡

```elixir
# Elements support event-related attributes
{:ok, clickable_button} = GenDOM.Element.Button.new(
  tag_name: "button",
  attributes: %{
    "onclick" => "handleClick()",
    "onmouseover" => "showTooltip()",
    "data-track" => "button-click"
  }
)

# Form elements with event attributes
{:ok, interactive_input} = GenDOM.Element.Input.new(
  tag_name: "input",
  type: "text",
  attributes: %{
    "onchange" => "validateInput(this)",
    "onfocus" => "highlightField(this)",
    "onblur" => "checkRequired(this)"
  }
)
```

## 🏗️ Architecture

GenDOM implements a proper DOM inheritance hierarchy:

```
GenDOM.Node (base)
└── GenDOM.Element
    ├── GenDOM.Element.Form (implements FormElement interface)
    ├── GenDOM.Element.Button  
    └── GenDOM.Element.Input
```

### Key Features:

- 🧬 **Field Inheritance**: Child elements inherit all parent fields with override capability
- 📤 **Method Inheritance**: All parent methods available on child elements via delegation
- 🔄 **Proper Override**: Child modules can override parent behavior using `defoverridable`
- ⚙️ **Process Management**: Each node runs as a GenServer for state isolation

## 📚 API Documentation

### Core Modules

- **`GenDOM.Node`** 🌳 - Base DOM node functionality, text content, child management
- **`GenDOM.Element`** 🏷️ - Element-specific features, attributes, CSS classes, selectors  
- **`GenDOM.Document`** 📄 - Document-level operations, parsing, global queries
- **`GenDOM.Element.Form`** 📋 - Form elements with validation and submission (FormElement interface)
- **`GenDOM.Element.Button`** 🔘 - Button elements with interaction support
- **`GenDOM.Element.Input`** ⌨️ - Input elements with validation and various types

### Utility Modules

- **`GenDOM.Parser`** 🔧 - Parse templates and convert to DOM structures
- **`GenDOM.QuerySelector`** 🎯 - CSS selector parsing and matching
- **`GenDOM.Matcher`** 🔍 - Element matching and filtering logic

## 🔍 CSS Selector Support

GenDOM uses the [Selector](https://github.com/liveview-native/selector) library to provide comprehensive CSS selector syntax support:

```elixir
# Basic selectors
"div"                    # Tag selector
".class-name"           # Class selector  
"#element-id"          # ID selector
"*"                    # Universal selector

# Combinators
"div p"                # Descendant
"div > p"              # Direct child
"div + p"              # Adjacent sibling
"div ~ p"              # General sibling

# Attribute selectors
"[href]"               # Has attribute
"[href='#']"           # Exact match
"[href*='example']"    # Contains
"[href^='https']"      # Starts with
"[href$='.pdf']"       # Ends with

# Pseudo-classes
":first-child"         # First child
":last-child"          # Last child
":nth-child(2n+1)"     # Nth child (odd)
":not(.excluded)"      # Negation

# Complex combinations
"form input[type='email']:required"
".container > .content p:first-child"
"nav ul li:not(.active) a[href^='/']"
```

## 🚀 Performance Considerations

- **Process Efficiency**: Each DOM node is a lightweight GenServer
- **Memory Management**: Automatic cleanup when nodes are removed from DOM
- **Selector Optimization**: CSS selectors are parsed once and reused
- **Lazy Evaluation**: Queries return results only when accessed

## 🧪 Testing

Run the comprehensive test suite:

```bash
mix test
```

Generate test coverage:

```bash
mix test --cover
```

## 📖 Documentation

Generate documentation:

```bash
mix docs
```

View generated documentation:

```bash
open doc/index.html
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`mix test`)
5. Commit your changes (`git commit -am 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 🗺️ Roadmap

- [ ] 🎨 CSS property manipulation
- [ ] ⚡ Event system implementation  
- [ ] 🔄 Live DOM synchronization
- [ ] 📱 Mobile-specific DOM features
- [ ] 🌐 Web Component support
- [ ] 🔧 DevTools integration

## 🐛 Known Issues

None at this time! Please report any issues you encounter.

## 💡 Examples Repository

Check out the [examples repository](https://github.com/liveview-native/gen_dom_examples) for more detailed usage examples and common patterns.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

Made with ❤️ by [DockYard, Inc.](https://dockyard.com)