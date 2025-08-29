# GenDOM Agent Instructions

## Build & Test Commands
- Run tests: `mix test`
- Run single test file: `mix test test/gen_dom/element_test.exs`
- Run with coverage: `mix test --cover`
- Format code: `mix format`
- Generate docs: `mix docs`
- Compile: `mix compile`

## Code Style Guidelines
- Use snake_case for functions, variables, atoms, and file names
- Convert camelCase DOM API names to snake_case (e.g., `getElementById` → `get_element_by_id`)
- Module names use PascalCase (e.g., `GenDOM.Element`)
- Use 2-space indentation (enforced by `.formatter.exs`)
- No trailing commas in lists/maps
- Comprehensive @moduledoc and @doc for all public functions
- Follow existing import patterns: alias multiple modules in blocks
- Unless specifically asked functions don't return tuples in this library
* when writing heredocs make sure any nested documentation that uses Elixir interpolation is properly escaped

## DOM Implementation Architecture
This library implements the DOM API in Elixir using GenGraph, GenObject, and Inherit libraries.

**References:**
- DOM Spec: https://www.w3.org/DOM/DOMTR
- MDN DOM API: https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model
- GenGraph: https://hexdocs.pm/gen_graph
- GenObject: https://hexdocs.pm/gen_object  
- Inherit: https://hexdocs.pm/inherit

**DOM Class Implementation:**
- Instance properties → struct fields via Inherit
- Static methods → module functions
- Instance methods → functions with struct as first param: `foo_bar(%__MODULE__{} = object, arg1, arg2)`
- Inheritance: `use GenDOM.Parent` or `use GenObject` for base classes
- File naming: `lib/gen_dom/snake_case.ex` for DOM class FooBar
