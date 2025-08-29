defmodule GenDOM.Iterator do
  @moduledoc """
  DOM Iterator implementation for Elixir.

  Provides Web API-compatible iteration while leveraging Elixir's capabilities.
  This bridges the JavaScript iterator protocol with Elixir's functional iteration patterns.

  ## JavaScript Iterator Protocol

  In JavaScript, iterators have:
  - `next()` method returning `{value, done}` objects
  - `Symbol.iterator` method for for-of loops

  ## Elixir Implementation

  This module provides:
  - `next/1` method returning `{:ok, value, new_iterator}` or `:done`
  - Integration with Elixir's Stream and Enumerable
  - Immutable iterator advancement

  ## Examples

      # Create iterator from HTMLCollection
      collection = GenDOM.Document.get_elements_by_tag_name(doc, "div")
      iterator = GenDOM.Iterator.new(collection)

      # Use next() like JavaScript
      case GenDOM.Iterator.next(iterator) do
        {:ok, element, next_iterator} -> 
          IO.puts("Found element")
          GenDOM.Iterator.next(next_iterator)  # Continue with new state
        :done -> 
          IO.puts("No more elements")
      end

      # Or use Elixir Stream patterns
      iterator
      |> GenDOM.Iterator.to_stream()
      |> Stream.take(5)
      |> Enum.to_list()
  """

  defstruct [
    # Source collection or enumerable
    source: nil,
    # Current position  
    current_index: 0,
    # :html_collection, :node_list, :dom_token_list, etc.
    source_type: nil,
    # Whether iteration is complete
    done: false,
    # Cached length for performance
    cached_length: nil
  ]

  @doc """
  Creates a new iterator from any DOM collection or enumerable.

  Uses pattern matching to determine the appropriate iterator type based on the input.

  ## Parameters

  - `source` - The collection or enumerable to iterate over

  ## Returns

  A new `%GenDOM.Iterator{}` struct configured for the source type.

  ## Examples

      # From HTMLCollection
      iterator = GenDOM.Iterator.new(html_collection)

      # From NodeList  
      iterator = GenDOM.Iterator.new(node_list)

      # From DOMTokenList
      iterator = GenDOM.Iterator.new(token_list)

      # From list
      iterator = GenDOM.Iterator.new([1, 2, 3])

      # From stream
      iterator = GenDOM.Iterator.new(Stream.cycle([1, 2, 3]))

  ## Web API Reference

  This corresponds to calling `collection[Symbol.iterator]()` in JavaScript.
  """
  def new(%GenDOM.HTMLCollection{} = collection) do
    %__MODULE__{
      source: collection,
      source_type: :html_collection,
      current_index: 0,
      done: false,
      cached_length: GenDOM.HTMLCollection.length(collection)
    }
  end

  # def new(%GenDOM.NodeList{} = node_list) do
  #   %__MODULE__{
  #     source: node_list, 
  #     source_type: :node_list,
  #     current_index: 0,
  #     done: false,
  #     cached_length: GenDOM.NodeList.length(node_list)
  #   }
  # end

  # def new(%GenDOM.DOMTokenList{} = token_list) do
  #   %__MODULE__{
  #     source: token_list,
  #     source_type: :dom_token_list, 
  #     current_index: 0,
  #     done: false,
  #     cached_length: GenDOM.DOMTokenList.length(token_list)
  #   }
  # end

  def new(list) when is_list(list) do
    %__MODULE__{
      source: list,
      source_type: :list,
      current_index: 0,
      done: false,
      cached_length: length(list)
    }
  end

  def new(%Stream{} = stream) do
    %__MODULE__{
      source: stream,
      source_type: :stream,
      current_index: 0,
      done: false,
      # Streams might be infinite
      cached_length: nil
    }
  end

  def new(enumerable) do
    # Fallback for any enumerable
    list = Enum.to_list(enumerable)
    new(list)
  end

  @doc """
  Advances the iterator and returns the next value.

  Returns `{:ok, value, new_iterator}` if there's a next value, 
  or `:done` if iteration is complete.

  This mirrors the JavaScript iterator `next()` method behavior
  while maintaining Elixir's immutability.

  ## Parameters

  - `iterator` - The iterator struct to advance

  ## Returns

  - `{:ok, value, new_iterator}` - Next value and updated iterator state
  - `:done` - No more values available

  ## Examples

      iterator = GenDOM.Iterator.new([1, 2, 3])
      
      case GenDOM.Iterator.next(iterator) do
        {:ok, 1, next_iter} -> 
          case GenDOM.Iterator.next(next_iter) do
            {:ok, 2, next_iter2} -> 
              GenDOM.Iterator.next(next_iter2)  # {:ok, 3, final_iter}
            :done -> 
              IO.puts("Unexpected end")
          end
        :done -> 
          IO.puts("Empty iterator")
      end

  ## Web API Reference

  [MDN Web Docs: Iterator.next()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols#the_iterator_protocol)
  """
  def next(%__MODULE__{done: true}), do: :done

  def next(%__MODULE__{current_index: index, cached_length: length} = iterator)
      when is_integer(length) and index >= length do
    :done
  end

  def next(%__MODULE__{source_type: :html_collection} = iterator) do
    case GenDOM.HTMLCollection.item(iterator.source, iterator.current_index) do
      nil ->
        :done

      value ->
        new_iterator = %{iterator | current_index: iterator.current_index + 1}
        {:ok, value, new_iterator}
    end
  end

  # def next(%__MODULE__{source_type: :node_list} = iterator) do  
  #   case GenDOM.NodeList.item(iterator.source, iterator.current_index) do
  #     nil ->
  #       :done
  #     value ->
  #       new_iterator = %{iterator | current_index: iterator.current_index + 1}
  #       {:ok, value, new_iterator}
  #   end
  # end

  # def next(%__MODULE__{source_type: :dom_token_list} = iterator) do
  #   case GenDOM.DOMTokenList.item(iterator.source, iterator.current_index) do
  #     nil ->
  #       :done
  #     value ->
  #       new_iterator = %{iterator | current_index: iterator.current_index + 1}
  #       {:ok, value, new_iterator}
  #   end
  # end

  # def next(%__MODULE__{source_type: :dom_token_list} = iterator) do
  #   case GenDOM.DOMTokenList.item(iterator.source, iterator.current_index) do
  #     nil ->
  #       :done

  #     value ->
  #       new_iterator = %{iterator | current_index: iterator.current_index + 1}
  #       {:ok, value, new_iterator}
  #   end
  # end

  def next(%__MODULE__{source_type: :list} = iterator) do
    case Enum.at(iterator.source, iterator.current_index) do
      nil ->
        :done

      value ->
        new_iterator = %{iterator | current_index: iterator.current_index + 1}
        {:ok, value, new_iterator}
    end
  end

  def next(%__MODULE__{source_type: :stream} = iterator) do
    # For streams, we need to track consumed elements differently
    stream_slice =
      iterator.source
      |> Stream.drop(iterator.current_index)
      |> Stream.take(1)
      |> Enum.to_list()

    case stream_slice do
      [] ->
        :done

      [value] ->
        new_iterator = %{iterator | current_index: iterator.current_index + 1}
        {:ok, value, new_iterator}
    end
  end

  @doc """
  Converts iterator to Elixir Stream for functional programming.

  Creates a lazy stream from the iterator that can be used with Elixir's
  Stream and Enum modules for functional operations.

  ## Parameters

  - `iterator` - The iterator to convert

  ## Returns

  A `Stream` that yields values from the iterator.

  ## Examples

      iterator = GenDOM.Iterator.new([1, 2, 3, 4, 5])
      
      # Use with Stream operations
      result = iterator
      |> GenDOM.Iterator.to_stream()
      |> Stream.filter(&(&1 > 2))
      |> Stream.take(2)
      |> Enum.to_list()
      # Result: [3, 4]

      # Use with Enum operations  
      sum = iterator
      |> GenDOM.Iterator.to_stream()
      |> Enum.sum()
      # Result: 15

  ## Web API Reference

  This enables JavaScript-like `for...of` iteration patterns in Elixir.
  """
  def to_stream(%__MODULE__{} = iterator) do
    Stream.unfold(iterator, fn iter ->
      case next(iter) do
        {:ok, value, new_iter} -> {value, new_iter}
        :done -> nil
      end
    end)
  end

  @doc """
  Resets iterator to the beginning.

  Creates a new iterator with the same source but reset to the initial position.
  This allows reiterating over the same collection.

  ## Parameters

  - `iterator` - The iterator to reset

  ## Returns

  A new iterator positioned at the beginning of the collection.

  ## Examples

      iterator = GenDOM.Iterator.new([1, 2, 3])
      
      # Advance iterator
      {:ok, 1, next_iter} = GenDOM.Iterator.next(iterator)
      {:ok, 2, next_iter2} = GenDOM.Iterator.next(next_iter)
      
      # Reset to beginning
      reset_iter = GenDOM.Iterator.reset(iterator)
      {:ok, 1, _} = GenDOM.Iterator.next(reset_iter)  # Back to start

  ## Web API Reference

  While JavaScript iterators don't have a reset method, this provides
  convenient reusability for Elixir patterns.
  """
  def reset(%__MODULE__{} = iterator) do
    %{iterator | current_index: 0, done: false}
  end
end
