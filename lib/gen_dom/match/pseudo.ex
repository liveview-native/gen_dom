defmodule GenDOM.Match.Pseudo do
  @moduledoc false

  import GenDOM.Document, only: [
    await_one: 1,
    await_many: 1
  ]

  alias GenDOM.Element

  def match(%Element{} = element, "not", [params], opts) do
    opts = Keyword.merge(opts, recursive: false, await: &await_one/1)

    tasks = Enum.map(params, fn(param) ->
      Task.async fn ->
        Element.match(element, param, opts)
      end
    end)

    case await_one(tasks) do
      nil -> element
      _element -> nil
    end
  end
end
