defmodule GenDOM.Element.FormTest do
  use ExUnit.Case, async: true

  alias GenDOM.Element.Form
  alias GenDOM.Element

  describe "inheritance from Element with FormElement properties" do
    test "inherits all Element fields and has FormElement fields" do
      form = Form.new(
        # Form-specific fields
        accept: "image/*",
        accept_charset: "UTF-8",
        autocomplete: "on",
        novalidate: true,
        
        # FormElement fields
        action: "/api/forms",
        method: "post",
        name: "contact-form",
        target: "_self",
        
        # Element fields
        tag_name: "form",
        id: "contact-form-id",
        class_list: ["form", "validated"]
      )

      # Should have Node fields (through Element -> FormElement)
      assert form.node_type == 1
      assert form.text_content == ""
      assert form.child_nodes == []

      # Should have Element fields (through FormElement)
      assert form.tag_name == "form"
      assert form.id == "contact-form-id"
      assert form.class_list == ["form", "validated"]
      assert form.attributes == %{}

      # Should have FormElement fields
      assert form.action == "/api/forms"
      assert form.method == "post"
      assert form.name == "contact-form"
      assert form.target == "_self"
      assert form.elements == []
      assert form.length == 0
      assert form.no_validate == false  # FormElement default

      # Should have Form-specific fields
      assert form.accept == "image/*"
      assert form.accept_charset == "UTF-8"
      assert form.autocomplete == "on"
      assert form.novalidate == true
    end

    test "can use Node methods" do
      form = Form.new(tag_name: "form")
      
      # Should be able to call Node methods
      assert Form.has_child_nodes?(form) == false
      assert Form.is_same_node?(form, form) == true
      
      # Test adding child elements
      input = Element.new(tag_name: "input")
      Form.append_child(form.pid, input.pid)
      assert Form.has_child_nodes?(form.pid) == true
    end

    test "can use Element methods" do
      form = Form.new(
        tag_name: "form",
        attributes: %{"class" => "contact-form", "data-validation" => "true"}
      )
      
      # Should be able to call Element methods
      assert Form.get_attribute(form.pid, "class") == "contact-form"
      assert Form.get_attribute(form.pid, "data-validation") == "true"
      assert Form.has_attribute?(form.pid, "class") == true
      assert Form.has_attribute?(form.pid, "nonexistent") == false

      # Test attribute manipulation
      Form.set_attribute(form.pid, "method", "post")
      assert Form.get_attribute(form.pid, "method") == "post"
    end

    test "can use FormElement methods" do
      form = Form.new(tag_name: "form")
      
      # Should have FormElement methods
      assert function_exported?(Form, :check_validity, 1)
      assert function_exported?(Form, :report_validity, 1)
      assert function_exported?(Form, :request_submit, 1)
      assert function_exported?(Form, :reset, 1)
      assert function_exported?(Form, :submit, 1)
    end
  end

  describe "Form-specific functionality" do
    test "sets form-specific default values" do
      form = Form.new(tag_name: "form")
      
      # Form-specific fields should have appropriate defaults
      assert form.accept == nil
      assert form.accept_charset == nil
      assert form.autocomplete == nil
      assert form.novalidate == nil
      assert form.rel == nil
    end

    test "can override FormElement defaults" do
      form = Form.new(
        tag_name: "form",
        action: "/custom-submit",
        method: "patch",
        name: "custom-form-name",
        target: "_blank"
      )
      
      # Should override FormElement defaults
      assert form.action == "/custom-submit"
      assert form.method == "patch"  # Override FormElement default of "get"
      assert form.name == "custom-form-name"
      assert form.target == "_blank"
    end
  end

  describe "FormElement fields" do
    test "Form fields work correctly" do
      # Form with FormElement fields
      form = Form.new(
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

    test "has all FormElement fields" do
      form = Form.new(tag_name: "form")
      
      # Should have FormElement fields
      assert form.elements == []       # From FormElement
      assert form.length == 0          # From FormElement
      assert form.no_validate == false # From FormElement
      assert form.rel_list == []       # From FormElement
    end
  end

  describe "encoding" do
    test "encodes all inherited fields correctly" do
      form = Form.new(
        tag_name: "form",
        id: "test-form",
        action: "/submit",
        method: "post",
        accept: "text/*",
        autocomplete: "on",
        novalidate: true,
        name: "test-form-name"
      )

      encoded = Form.encode(form)
      
      # Should include Node fields
      assert Map.has_key?(encoded, :node_type)
      assert Map.has_key?(encoded, :child_nodes)
      
      # Should include Element fields
      assert Map.has_key?(encoded, :tag_name)
      assert Map.has_key?(encoded, :id)
      assert encoded[:tag_name] == "form"
      assert encoded[:id] == "test-form"
      
      # Should include FormElement fields
      assert encoded[:action] == "/submit"
      assert encoded[:method] == "post"
      assert encoded[:name] == "test-form-name"
      
      # Should include Form-specific fields
      assert encoded[:accept] == "text/*"
      assert encoded[:autocomplete] == "on"
      assert encoded[:novalidate] == true
    end
  end

  describe "method inheritance chain" do
    test "has access to all methods from inheritance chain" do
      form = Form.new(tag_name: "form")
      
      # Node methods
      assert function_exported?(Form, :append_child, 2)
      assert function_exported?(Form, :clone_node, 1)
      assert function_exported?(Form, :contains?, 2)
      assert function_exported?(Form, :normalize, 1)
      
      # Element methods  
      assert function_exported?(Form, :get_attribute, 2)
      assert function_exported?(Form, :set_attribute, 3)
      assert function_exported?(Form, :query_selector, 2)
      assert function_exported?(Form, :get_elements_by_tag_name, 2)
      
      # FormElement methods
      assert function_exported?(Form, :check_validity, 1)
      assert function_exported?(Form, :report_validity, 1)
      assert function_exported?(Form, :submit, 1)
      assert function_exported?(Form, :reset, 1)
    end
  end

  describe "form submission methods" do
    test "form submission methods are available and callable" do
      form = Form.new(
        tag_name: "form",
        action: "/submit",
        method: "post"
      )
      
      # These should be callable (even if implementation is empty)
      # They shouldn't raise exceptions
      Form.check_validity(form.pid)
      Form.report_validity(form.pid)
      Form.request_submit(form.pid)
      Form.reset(form.pid)
      Form.submit(form.pid)
    end
  end
end
