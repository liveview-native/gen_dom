defmodule GenDOM.Element.Button do
  @derive {Inspect, only: [:pid, :tag_name, :id, :class_list, :attributes]}

  @moduledoc """
  Represents a button element.

  This module implements the ButtonElement interface as defined in the DOM specification.
  Button elements inherit from Element and include button-specific properties and behaviors.
  """

  use GenDOM.Element, [
    autofocus: nil,
    command: nil,
    commandfor: nil,
    disabled: nil,
    form: nil,
    formaction: nil,
    formenctype: nil,
    formmethod: nil,
    formnovalidate: nil,
    formtarget: nil,
    name: nil,
    popovertarget: nil,
    popovertargetaction: nil,
    type: nil,
    value: nil,
    id: nil,
    class: nil,
    style: nil,
    title: nil,
    lang: nil,
    dir: nil,
    tabindex: nil,
    accesskey: nil,
    contenteditable: nil,
    draggable: nil,
    hidden: nil,
    spellcheck: nil,
    translate: nil
  ]

  def check_validity(%__MODULE__{} = input) do

  end

  def report_validity(%__MODULE__{} = input) do

  end

  def set_custom_validity(%__MODULE__{} = input) do

  end

  def encode(button) do
    Map.merge(super(button), %{
      type: button.type,
      value: button.value,
      disabled: button.disabled,
      name: button.name
    })
  end
end
