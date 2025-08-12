defmodule GenDOM do
  @moduledoc """
  Use this module to alias all of the DOM API GenDOM modules into local scope

      defmodule MyElement do
        use GenDOM

        use Element, [
          name: nil,
        ]
      end
  """

  @disallowed [
    GenDOM,
    GenDOM.Application,
    GenDOM.EventRegistry,
    GenDOM.Matcher,
    GenDOM.Matcher.Psuedo,
    GenDOM.QuerySelector,
    GenDOM.Task
  ]

  @doc false
  defmacro __using__(_) do
    quoted =
      Application.spec(:gen_dom)[:modules]
      |> Enum.reject(&(&1 in @disallowed))
      |> Enum.map(fn(module) ->
        quote do
          alias unquote(module)
        end
      end)

    quote do
      unquote_splicing(quoted)
    end
  end
end
