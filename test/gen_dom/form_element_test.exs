defmodule GenDOM.FormElementTest do
  use ExUnit.Case, async: true

  test "FormElement module has been removed" do
    # FormElement was refactored - FormElement functionality 
    # is now only in GenDOM.Element.Form as per DOM spec
    refute Code.ensure_loaded?(GenDOM.FormElement)
  end
end