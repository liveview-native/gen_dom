defmodule GenDOM.HTMLFormElementTest do
  use ExUnit.Case, async: true

  alias GenDOM.HTMLFormElement
  alias GenDOM.Element

  describe "inheritance from Element with HTMLFormElementElement properties" do
    test "inherits all Element fields and has HTMLFormElementElement fields" do
      form = HTMLFormElement.new(
        # HTMLFormElement-specific fields
        accept_charset: "UTF-8",
        autocomplete: "on",
        no_validate: true,
        
        # HTMLFormElementElement fields
        action: "/api/forms",
        method: "post",
        name: "contact-form",
        target: "_self",
        
        # Element fields
        tag_name: "form",
        id: "contact-form-id",
        class_list: ["form", "validated"]
      )

      # Should have Node fields (through Element -> HTMLFormElementElement)
      assert form.node_type == 1
      assert form.text_content == ""
      assert form.child_nodes == []

      # Should have Element fields (through HTMLFormElementElement)
      assert form.tag_name == "form"
      assert form.id == "contact-form-id"
      assert form.class_list == ["form", "validated"]
      assert form.attributes == %{}

      # Should have HTMLFormElementElement fields
      assert form.action == "/api/forms"
      assert form.method == "post"
      assert form.name == "contact-form"
      assert form.target == "_self"
      assert form.elements == []
      assert form.length == 0
      assert form.no_validate == false  # HTMLFormElementElement default

      # Should have HTMLFormElement-specific fields
      assert form.accept_charset == "UTF-8"
      assert form.autocomplete == "on"
      assert form.no_validate == true
    end

    test "can use Node methods" do
      form = HTMLFormElement.new(tag_name: "form")
      
      # Should be able to call Node methods
      assert HTMLFormElement.has_child_nodes?(form) == false
      assert HTMLFormElement.is_same_node?(form, form) == true
      
      # Test adding child elements
      input = Element.new(tag_name: "input")
      HTMLFormElement.append_child(form.pid, input.pid)
      assert HTMLFormElement.has_child_nodes?(form.pid) == true
    end

    test "can use Element methods" do
      form = HTMLFormElement.new(
        tag_name: "form",
        attributes: %{"class" => "contact-form", "data-validation" => "true"}
      )
      
      # Should be able to call Element methods
      assert HTMLFormElement.get_attribute(form.pid, "class") == "contact-form"
      assert HTMLFormElement.get_attribute(form.pid, "data-validation") == "true"
      assert HTMLFormElement.has_attribute?(form.pid, "class") == true
      assert HTMLFormElement.has_attribute?(form.pid, "nonexistent") == false

      # Test attribute manipulation
      HTMLFormElement.set_attribute(form.pid, "method", "post")
      assert HTMLFormElement.get_attribute(form.pid, "method") == "post"
    end

    test "can use HTMLFormElementElement methods" do
      form = HTMLFormElement.new(tag_name: "form")
      
      # Should have HTMLFormElementElement methods
      assert function_exported?(HTMLFormElement, :check_validity, 1)
      assert function_exported?(HTMLFormElement, :report_validity, 1)
      assert function_exported?(HTMLFormElement, :request_submit, 1)
      assert function_exported?(HTMLFormElement, :reset, 1)
      assert function_exported?(HTMLFormElement, :submit, 1)
    end
  end

  describe "HTMLFormElement-specific functionality" do
    test "sets form-specific default values" do
      form = HTMLFormElement.new(tag_name: "form")
      
      # HTMLFormElement-specific fields should have appropriate defaults
      assert form.accept_charset == ""
      assert form.autocomplete == "on"
      assert form.no_validate == false
      assert form.rel == ""
    end

    test "can override HTMLFormElementElement defaults" do
      form = HTMLFormElement.new(
        tag_name: "form",
        action: "/custom-submit",
        method: "patch",
        name: "custom-form-name",
        target: "_blank"
      )
      
      # Should override HTMLFormElementElement defaults
      assert form.action == "/custom-submit"
      assert form.method == "patch"  # Override HTMLFormElementElement default of "get"
      assert form.name == "custom-form-name"
      assert form.target == "_blank"
    end
  end

  describe "HTMLFormElementElement fields" do
    test "HTMLFormElement fields work correctly" do
      # HTMLFormElement with HTMLFormElementElement fields
      form = HTMLFormElement.new(
        tag_name: "form",
        accept_charset: "ISO-8859-1",
        action: "/form-submit",
        autocomplete: "off",
        name: "form-name"
      )
      
      # Should have correct values
      assert form.accept_charset == "ISO-8859-1"
      assert form.action == "/form-submit"
      assert form.autocomplete == "off"
      assert form.name == "form-name"
    end

    test "has all HTMLFormElementElement fields" do
      form = HTMLFormElement.new(tag_name: "form")
      
      # Should have HTMLFormElementElement fields
      assert form.elements == []       # From HTMLFormElementElement
      assert form.length == 0          # From HTMLFormElementElement
      assert form.no_validate == false # From HTMLFormElementElement
      assert form.rel_list == []       # From HTMLFormElementElement
    end
  end

  describe "encoding" do
    test "encodes all inherited fields correctly" do
      form = HTMLFormElement.new(
        tag_name: "form",
        id: "test-form",
        action: "/submit",
        method: "post",
        autocomplete: "on",
        no_validate: true,
        name: "test-form-name"
      )

      encoded = HTMLFormElement.encode(form)
      
      # Should include Node fields
      assert Map.has_key?(encoded, :node_type)
      assert Map.has_key?(encoded, :child_nodes)
      
      # Should include Element fields
      assert Map.has_key?(encoded, :tag_name)
      assert Map.has_key?(encoded, :id)
      assert encoded[:tag_name] == "form"
      assert encoded[:id] == "test-form"
      
      # Should include HTMLFormElementElement fields
      assert encoded[:action] == "/submit"
      assert encoded[:method] == "post"
      assert encoded[:name] == "test-form-name"
      
      # Should include HTMLFormElement-specific fields
      assert encoded[:autocomplete] == "on"
      assert encoded[:no_validate] == true
    end
  end

  describe "method inheritance chain" do
    test "has access to all methods from inheritance chain" do
      form = HTMLFormElement.new(tag_name: "form")
      
      # Node methods
      assert function_exported?(HTMLFormElement, :append_child, 2)
      assert function_exported?(HTMLFormElement, :clone_node, 1)
      assert function_exported?(HTMLFormElement, :contains?, 2)
      assert function_exported?(HTMLFormElement, :normalize, 1)
      
      # Element methods  
      assert function_exported?(HTMLFormElement, :get_attribute, 2)
      assert function_exported?(HTMLFormElement, :set_attribute, 3)
      assert function_exported?(HTMLFormElement, :query_selector, 2)
      assert function_exported?(HTMLFormElement, :get_elements_by_tag_name, 2)
      
      # HTMLFormElementElement methods
      assert function_exported?(HTMLFormElement, :check_validity, 1)
      assert function_exported?(HTMLFormElement, :report_validity, 1)
      assert function_exported?(HTMLFormElement, :submit, 1)
      assert function_exported?(HTMLFormElement, :reset, 1)
    end
  end

  describe "form submission methods" do
    test "form submission methods are available and callable" do
      form = HTMLFormElement.new(
        tag_name: "form",
        action: "/submit",
        method: "post"
      )
      
      # These should be callable (even if implementation is empty)
      # They shouldn't raise exceptions
      HTMLFormElement.check_validity(form.pid)
      HTMLFormElement.report_validity(form.pid)
      HTMLFormElement.request_submit(form.pid)
      HTMLFormElement.reset(form.pid)
      HTMLFormElement.submit(form.pid)
    end
  end
end
