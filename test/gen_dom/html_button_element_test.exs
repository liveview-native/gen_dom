defmodule GenDOM.HTMLButtonElementTest do
  use ExUnit.Case, async: true

  alias GenDOM.HTMLButtonElement

  describe "inheritance from Element" do
    test "inherits all Element fields" do
      button = HTMLButtonElement.new(
        # HTMLButtonElement-specific fields
        type: "submit",
        value: "Submit Form",
        disabled: true,
        autofocus: true,
        name: "submit-btn",
        
        # Element fields
        tag_name: "button",
        id: "submit-button",
        class_list: ["btn", "btn-primary"]
      )

      # Should have Node fields (through Element)
      assert button.node_type == 1
      assert button.text_content == ""
      assert button.child_nodes == []

      # Should have Element fields
      assert button.tag_name == "button"
      assert button.id == "submit-button"
      assert button.class_list == ["btn", "btn-primary"]
      assert button.attributes == %{}

      # Should have HTMLButtonElement-specific fields
      assert button.type == "submit"
      assert button.value == "Submit Form"
      assert button.disabled == true
      assert button.name == "submit-btn"
      assert button.autofocus == true
    end

    test "can use Node methods" do
      button = HTMLButtonElement.new(tag_name: "button", type: "button")
      
      # Should be able to call Node methods
      assert HTMLButtonElement.has_child_nodes?(button.pid) == false
      assert HTMLButtonElement.is_same_node?(button.pid, button.pid) == true
      
      # Test cloning
      cloned_button_pid = HTMLButtonElement.clone_node(button.pid)
      cloned_button = HTMLButtonElement.get(cloned_button_pid)
      assert cloned_button.type == "button"
      assert cloned_button.pid != button.pid
    end

    test "can use Element methods" do
      button = HTMLButtonElement.new(
        tag_name: "button",
        type: "submit",
        attributes: %{"class" => "btn-primary", "data-action" => "submit"}
      )
      
      # Should be able to call Element methods
      assert HTMLButtonElement.get_attribute(button.pid, "class") == "btn-primary"
      assert HTMLButtonElement.get_attribute(button.pid, "data-action") == "submit"
      assert HTMLButtonElement.has_attribute?(button.pid, "class") == true
      assert HTMLButtonElement.has_attribute?(button.pid, "nonexistent") == false

      # Test setting attributes
      HTMLButtonElement.set_attribute(button.pid, "disabled", "true")
      assert HTMLButtonElement.get_attribute(button.pid, "disabled") == "true"
    end

  end

  describe "HTMLButtonElement-specific functionality" do
    test "sets button-specific default values" do
      button = HTMLButtonElement.new(tag_name: "button")
      
      # HTMLButtonElement-specific fields should have appropriate defaults
      assert button.autofocus == false
      assert button.command == ""
      assert button.disabled == false
      assert button.form == nil
      assert button.type == "submit"
      assert button.value == ""
    end

    test "supports button-specific attributes" do
      button = HTMLButtonElement.new(
        tag_name: "button",
        name: "my-button",
        type: "submit",
        value: "Submit Form",
        disabled: true,
        autofocus: true
      )
      
      assert button.name == "my-button"
      assert button.type == "submit"
      assert button.value == "Submit Form"
      assert button.disabled == true
      assert button.autofocus == true
    end
  end

  describe "encoding" do
    test "encodes all inherited fields correctly" do
      button = HTMLButtonElement.new(
        tag_name: "button",
        type: "submit",
        value: "Submit",
        disabled: true,
        id: "submit-btn",
        name: "submit-button"
      )

      encoded = HTMLButtonElement.encode(button)
      
      # Should include Node fields
      assert Map.has_key?(encoded, :node_type)
      assert Map.has_key?(encoded, :child_nodes)
      
      # Should include Element fields
      assert Map.has_key?(encoded, :tag_name)
      assert Map.has_key?(encoded, :id)
      assert encoded[:tag_name] == "button"
      assert encoded[:id] == "submit-btn"
      
      # Should include HTMLButtonElement-specific fields
      assert encoded[:type] == "submit"
      assert encoded[:value] == "Submit"
      assert encoded[:disabled] == true
      assert encoded[:name] == "submit-button"
    end
  end

  describe "method inheritance chain" do
    test "has access to all methods from inheritance chain" do
      button = HTMLButtonElement.new(tag_name: "button", type: "button")
      
      # Node methods
      assert function_exported?(HTMLButtonElement, :append_child, 2)
      assert function_exported?(HTMLButtonElement, :clone_node, 1)
      assert function_exported?(HTMLButtonElement, :contains?, 2)
      
      # Element methods  
      assert function_exported?(HTMLButtonElement, :get_attribute, 2)
      assert function_exported?(HTMLButtonElement, :set_attribute, 3)
      assert function_exported?(HTMLButtonElement, :query_selector, 2)
    end
  end
end
