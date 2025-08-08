defmodule GenDOM.HTMLInputElementTest do
  use ExUnit.Case, async: true

  alias GenDOM.HTMLInputElement

  describe "inheritance from Element" do
    test "inherits all Element fields" do
      input = HTMLInputElement.new(
        # Input-specific fields
        type: "email",
        value: "user@example.com",
        placeholder: "Enter your email",
        required: true,
        max_length: 50,
        pattern: ".*@.*",
        name: "email-input",
        autocomplete: "email",
        
        # Element fields
        tag_name: "input",
        id: "email-field",
        class_list: ["form-control", "required"]
      )

      # Should have Node fields (through Element)
      assert input.node_type == 1
      assert input.text_content == ""
      assert input.child_nodes == []

      # Should have Element fields
      assert input.tag_name == "input"
      assert input.id == "email-field"
      assert input.class_list == ["form-control", "required"]
      assert input.attributes == %{}

      # Should have Input-specific fields
      assert input.type == "email"
      assert input.value == "user@example.com"
      assert input.placeholder == "Enter your email"
      assert input.required == true
      assert input.max_length == 50
      assert input.pattern == ".*@.*"
    end

    test "can use Node methods" do
      input = HTMLInputElement.new(tag_name: "input", type: "text")
      
      # Should be able to call Node methods
      assert HTMLInputElement.has_child_nodes?(input) == false
      assert HTMLInputElement.is_same_node?(input, input) == true
      
      # Test cloning
      cloned_input_pid = HTMLInputElement.clone_node(input.pid)
      cloned_input = HTMLInputElement.get(cloned_input_pid)
      assert cloned_input.type == "text"
      assert cloned_input.pid != input.pid
    end

    test "can use Element methods" do
      input = HTMLInputElement.new(
        tag_name: "input",
        type: "text",
        attributes: %{"class" => "form-input", "data-validation" => "required"}
      )
      
      # Should be able to call Element methods
      assert HTMLInputElement.get_attribute(input.pid, "class") == "form-input"
      assert HTMLInputElement.get_attribute(input.pid, "data-validation") == "required"
      assert HTMLInputElement.has_attribute?(input.pid, "class") == true
      assert HTMLInputElement.has_attribute?(input.pid, "nonexistent") == false

      # Test attribute manipulation
      HTMLInputElement.set_attribute(input.pid, "value", "new value")
      assert HTMLInputElement.get_attribute(input.pid, "value") == "new value"
    end
  end

  describe "Input-specific functionality" do
    test "sets input-specific default values" do
      input = HTMLInputElement.new(tag_name: "input")
      
      # Input-specific fields should have appropriate defaults
      assert input.accept == ""
      assert input.alt == ""
      assert input.checked == false
      assert input.disabled == false
      assert input.form == nil
      assert input.type == "text"
      assert input.value == ""
      assert input.required == false
      assert input.readonly == false
    end

    test "supports various input types" do
      # Test different input types
      text_input = HTMLInputElement.new(tag_name: "input", type: "text", value: "text value")
      email_input = HTMLInputElement.new(tag_name: "input", type: "email", value: "user@example.com")
      password_input = HTMLInputElement.new(tag_name: "input", type: "password", value: "secret")
      checkbox_input = HTMLInputElement.new(tag_name: "input", type: "checkbox", checked: true)
      
      assert text_input.type == "text"
      assert text_input.value == "text value"
      
      assert email_input.type == "email"
      assert email_input.value == "user@example.com"
      
      assert password_input.type == "password"
      assert password_input.value == "secret"
      
      assert checkbox_input.type == "checkbox"
      assert checkbox_input.checked == true
    end
  end

  describe "encoding" do
    test "encodes all inherited fields correctly" do
      input = HTMLInputElement.new(
        tag_name: "input",
        type: "email",
        value: "test@example.com",
        placeholder: "Email address",
        required: true,
        id: "email-input",
        name: "user-email",
        action: "/validate",
        autocomplete: "email"
      )

      encoded = HTMLInputElement.encode(input)
      
      # Should include Node fields
      assert Map.has_key?(encoded, :node_type)
      assert Map.has_key?(encoded, :child_nodes)
      
      # Should include Element fields
      assert Map.has_key?(encoded, :tag_name)
      assert Map.has_key?(encoded, :id)
      assert encoded[:tag_name] == "input"
      assert encoded[:id] == "email-input"
      
      # Should include Input-specific fields
      assert encoded[:type] == "email"
      assert encoded[:value] == "test@example.com"
      assert encoded[:placeholder] == "Email address"
      assert encoded[:required] == true
    end
  end

  describe "method inheritance chain" do
    test "has access to all methods from inheritance chain" do
      _input = HTMLInputElement.new(tag_name: "input", type: "text")
      
      # Node methods
      assert function_exported?(HTMLInputElement, :append_child, 2)
      assert function_exported?(HTMLInputElement, :clone_node, 1)
      assert function_exported?(HTMLInputElement, :contains?, 2)
      assert function_exported?(HTMLInputElement, :normalize, 1)
      
      # Element methods  
      assert function_exported?(HTMLInputElement, :get_attribute, 2)
      assert function_exported?(HTMLInputElement, :set_attribute, 3)
      assert function_exported?(HTMLInputElement, :query_selector, 2)
      assert function_exported?(HTMLInputElement, :has_attribute?, 2)
    end
  end

  describe "input validation attributes" do
    test "supports validation-related attributes" do
      input = HTMLInputElement.new(
        tag_name: "input",
        type: "text",
        required: true,
        min_length: 5,
        max_length: 20,
        pattern: "[A-Za-z]+",
        placeholder: "Enter text"
      )
      
      assert input.required == true
      assert input.min_length == 5
      assert input.max_length == 20
      assert input.pattern == "[A-Za-z]+"
      assert input.placeholder == "Enter text"
    end

    test "supports numeric input attributes" do
      input = HTMLInputElement.new(
        tag_name: "input",
        type: "number",
        min: 0,
        max: 100,
        step: 5,
        value: "50"
      )
      
      assert input.type == "number"
      assert input.min == 0
      assert input.max == 100
      assert input.step == 5
      assert input.value == "50"
    end
  end
end
