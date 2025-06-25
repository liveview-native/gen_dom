defmodule GenDOM.QuerySelector do
  @moduledoc false

  import GenDOM.Task
  alias GenDOM.Matcher

  defmacro __using__(_opts) do
    quote do
      def query_selector(%__MODULE__{} = node, selectors) when is_binary(selectors) do
        selectors = Selector.parse(selectors)
        all_descendants = :pg.get_members(node.pid)

        tasks = Enum.map(all_descendants, fn(pid) ->
          Task.async(fn ->
            element = GenServer.call(pid, :get)
            Matcher.match(element, selectors, await: &await_one/1)
          end)
        end)

        await_one(tasks)
      end

      def query_selector_all(%__MODULE__{} = node, selectors) when is_binary(selectors) do
        selectors = Selector.parse(selectors)
        all_descendants = :pg.get_members(node.pid)

        tasks = Enum.map(all_descendants, fn(pid) ->
          Task.async(fn ->
            case GenServer.call(pid, :get) do
              %GenDOM.Element{} = element ->
                Matcher.match(element, selectors, await: &await_many/1)
              _node ->
                nil
            end
          end)
        end)

        await_many(tasks)
        |> List.flatten()
        |> Enum.uniq()
      end
    end
  end
end
