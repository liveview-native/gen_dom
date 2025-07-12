defmodule GenDOM.QuerySelector do
  @moduledoc """
  Query selector functionality for GenDOM.

  This module provides CSS selector querying capabilities similar to the Web API's
  `querySelector()` and `querySelectorAll()` methods. It allows finding elements
  within the DOM tree using CSS selector syntax.

  CSS selector parsing is handled by the Selector library, which converts selector
  strings into parseable structures for matching against DOM elements.

  ## Usage

  To use QuerySelector functionality in your module:

      defmodule MyModule do
        use GenDOM.QuerySelector
        
        # Now you can use query_selector/2 and query_selector_all/2
      end

  ## CSS Selector Support

  Supports standard CSS selector syntax including:
  - Element selectors: `"div"`, `"p"`, `"span"`
  - Class selectors: `".classname"`
  - ID selectors: `"#idname"`
  - Attribute selectors: `"[attribute]"`, `"[attribute=value]"`
  - Pseudo-class selectors: `":not()"`, `":first-child"`
  - Combinators: `" "` (descendant), `">"` (child), `"+"` (adjacent sibling)
  """

  import GenDOM.Task

  defmacro __using__(_opts) do
    quote location: :keep do
      @doc """
      Returns the first element that matches the specified CSS selector.

      This method performs a depth-first pre-order traversal of the node's descendants
      and returns the first element that matches the given CSS selector string.
      If no matches are found, returns `nil`.

      ## Parameters

      - `node` - The root node to search within
      - `selectors` - A string containing CSS selector(s) to match against

      ## Returns

      - The first matching element, or `nil` if no matches are found
      - Uses concurrent tasks to search descendants efficiently

      ## Examples

          iex> node |> query_selector(".my-class")
          %Element{tag: "div", attributes: %{"class" => "my-class"}}

          iex> node |> query_selector("p.highlight")
          %Element{tag: "p", attributes: %{"class" => "highlight"}}

          iex> node |> query_selector("#nonexistent")
          nil

      """
      def query_selector(node_pid, selectors) when is_binary(selectors) do
        selectors = Selector.parse(selectors)
        query_selector(node_pid, selectors)
      end

      def query_selector(node_pid, selectors) do
        all_descendants = :pg.get_members(node_pid)

        tasks = Enum.map(all_descendants, fn(pid) ->
          Task.async(fn ->
            element = GenServer.call(pid, :get)
            GenDOM.Matcher.match(element, selectors, await: &await_one/1)
          end)
        end)

        case await_one(tasks) do
          %{pid: pid} -> pid
          other -> other
        end
      end

      @doc """
      Returns all elements that match the specified CSS selector.

      This method searches through all descendants of the node and returns a list
      of all elements that match the given CSS selector string. Elements are returned
      in document order and duplicates are removed.

      ## Parameters

      - `node` - The root node to search within
      - `selectors` - A string containing CSS selector(s) to match against

      ## Returns

      - A list of all matching elements
      - Returns an empty list if no matches are found
      - Results are flattened, deduplicated, and ordered by document position

      ## Examples

          iex> node |> query_selector_all(".item")
          [%Element{tag: "div", attributes: %{"class" => "item"}}, 
           %Element{tag: "span", attributes: %{"class" => "item"}}]

          iex> node |> query_selector_all("div, span")
          [%Element{tag: "div"}, %Element{tag: "span"}]

          iex> node |> query_selector_all(".nonexistent")
          []

      """
      def query_selector_all(node_pid, selectors) when is_binary(selectors) do
        selectors = Selector.parse(selectors)
        query_selector_all(node_pid, selectors)
      end

      def query_selector_all(node_pid, selectors) do
        all_descendants = :pg.get_members(node_pid)

        tasks = Enum.map(all_descendants, fn(pid) ->
          Task.async(fn ->
            node = GenServer.call(pid, :get)

            if node.is_element?,
              do: GenDOM.Matcher.match(node, selectors, await: &await_many/1),
              else: nil
          end)
        end)

        await_many(tasks)
        |> flat_uniq(MapSet.new([]))
        |> MapSet.to_list()
      end

      defp flat_uniq([], acc) do
        acc
      end

      defp flat_uniq([[]], acc) do
        acc
      end

      defp flat_uniq([[] |  elements], acc) do
        flat_uniq(elements, acc)
      end

      defp flat_uniq([element_list | elements], acc) when is_list(element_list) do
        acc = flat_uniq(element_list, acc)
        flat_uniq(elements, acc)
      end

      defp flat_uniq([element | []], acc) do
        MapSet.put(acc, element.pid)
      end

      defp flat_uniq([element | elements], acc) do
        flat_uniq(elements, MapSet.put(acc, element.pid))
      end
    end
  end
end
