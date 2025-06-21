defmodule GenDOM.Element.Input do
  @derive {Inspect, only: [:pid, :tag_name, :id, :class_list, :attributes]}

  @moduledoc """
  Represents an input element.

  This module implements the InputElement interface as defined in the DOM specification.
  Input elements inherit from Element and include input-specific properties and behaviors.
  """

  use GenDOM.Element, [
    accept: nil,
    alt: nil,
    autocomplete: nil,
    autofocus: nil,
    capture: nil,
    checked: nil,
    dirname: nil,
    disabled: nil,
    form: nil,
    formaction: nil,
    formenctype: nil,
    formmethod: nil,
    formnovalidate: nil,
    formtarget: nil,
    height: nil,
    list: nil,
    max: nil,
    maxlength: nil,
    min: nil,
    minlength: nil,
    multiple: nil,
    name: nil,
    pattern: nil,
    placeholder: nil,
    popovertarget: nil,
    popovertargetaction: nil,
    readonly: nil,
    required: nil,
    size: nil,
    src: nil,
    step: nil,
    type: nil,
    value: nil,
    width: nil,
    incremental: nil,
    mozactionhint: nil,
    orient: nil,
    results: nil,
    webkitdirectory: nil
  ]

end
