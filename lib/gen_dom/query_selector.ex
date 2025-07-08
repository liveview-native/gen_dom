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
  alias GenDOM.{
    Matcher,
    Node,
    Text
  }

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
      def query_selector_all(%__MODULE__{} = node, selectors) when is_binary(selectors) do
        selectors = Selector.parse(selectors)
        all_descendants = :pg.get_members(node.pid)

        tasks = Enum.map(all_descendants, fn(pid) ->
          Task.async(fn ->
            case GenServer.call(pid, :get) do
              %Node{} -> nil
              %Text{} -> nil
              element ->
                Matcher.match(element, selectors, await: &await_many/1)
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
