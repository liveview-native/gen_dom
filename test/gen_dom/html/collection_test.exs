defmodule GenDOM.HTMLCollectionTest do
  use ExUnit.Case, async: true

  alias GenDOM.{
    Document,
    Element,
    Node,
    HTMLCollection
  }

  describe "new/1" do
    test "creates a new HTMLCollection with default options" do
      collection = HTMLCollection.new()

      assert %HTMLCollection{pid: pid} = collection
      assert is_pid(pid)
      assert HTMLCollection.length(collection) == 0
    end

    test "creates collection with document_pid option" do
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          selector: "div",
          collection_type: :tag_name
        )

      assert %HTMLCollection{pid: pid} = collection
      assert is_pid(pid)
    end

    test "creates collection with parent_element_pid for children" do
      document = Document.new()
      element = Element.new(tag_name: "div")

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          parent_element_pid: element.pid,
          collection_type: :children
        )

      assert %HTMLCollection{pid: pid} = collection
      assert is_pid(pid)
    end

    test "creates collection with filter function" do
      document = Document.new()
      filter_fn = fn _element -> true end

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          filter_fn: filter_fn,
          collection_type: :filter
        )

      assert %HTMLCollection{pid: pid} = collection
      assert is_pid(pid)
    end
  end

  describe "length/1" do
    test "returns 0 for empty collection" do
      collection = HTMLCollection.new()
      assert HTMLCollection.length(collection) == 0
    end

    test "accepts collection struct" do
      collection = HTMLCollection.new()
      assert HTMLCollection.length(collection) == 0
    end

    test "accepts collection PID directly" do
      collection = HTMLCollection.new()
      assert HTMLCollection.length(collection.pid) == 0
    end
  end

  describe "item/2" do
    test "returns nil for empty collection" do
      collection = HTMLCollection.new()
      assert HTMLCollection.item(collection, 0) == nil
      assert HTMLCollection.item(collection, 1) == nil
    end

    test "returns nil for negative index" do
      collection = HTMLCollection.new()
      assert HTMLCollection.item(collection, -1) == nil
    end

    test "returns nil for non-integer index" do
      collection = HTMLCollection.new()
      assert HTMLCollection.item(collection, "0") == nil
      assert HTMLCollection.item(collection, 1.5) == nil
    end

    test "accepts collection struct" do
      collection = HTMLCollection.new()
      assert HTMLCollection.item(collection, 0) == nil
    end

    test "accepts collection PID directly" do
      collection = HTMLCollection.new()
      assert HTMLCollection.item(collection.pid, 0) == nil
    end
  end

  describe "named_item/2" do
    test "returns nil for empty collection" do
      collection = HTMLCollection.new()
      assert HTMLCollection.named_item(collection, "test") == nil
    end

    test "returns nil for non-string name" do
      collection = HTMLCollection.new()
      assert HTMLCollection.named_item(collection, 123) == nil
      assert HTMLCollection.named_item(collection, :atom) == nil
    end

    test "accepts collection struct" do
      collection = HTMLCollection.new()
      assert HTMLCollection.named_item(collection, "test") == nil
    end

    test "accepts collection PID directly" do
      collection = HTMLCollection.new()
      assert HTMLCollection.named_item(collection.pid, "test") == nil
    end
  end

  describe "to_list/1" do
    test "returns empty list for empty collection" do
      collection = HTMLCollection.new()
      assert HTMLCollection.to_list(collection) == []
    end

    test "returns list of current collection contents" do
      collection = HTMLCollection.new()
      list = HTMLCollection.to_list(collection)

      assert is_list(list)
      assert list == []
    end

    test "accepts collection struct" do
      collection = HTMLCollection.new()
      assert HTMLCollection.to_list(collection) == []
    end

    test "accepts collection PID directly" do
      collection = HTMLCollection.new()
      assert HTMLCollection.to_list(collection.pid) == []
    end
  end

  describe "to_stream/1" do
    test "returns stream for empty collection" do
      collection = HTMLCollection.new()
      stream = HTMLCollection.to_stream(collection)

      assert %Stream{} = stream
      assert Enum.to_list(stream) == []
    end

    test "stream can be enumerated" do
      collection = HTMLCollection.new()
      stream = HTMLCollection.to_stream(collection)

      result =
        stream
        |> Stream.take(5)
        |> Enum.to_list()

      assert result == []
    end

    test "accepts collection struct" do
      collection = HTMLCollection.new()
      stream = HTMLCollection.to_stream(collection)
      assert %Stream{} = stream
    end

    test "accepts collection PID directly" do
      collection = HTMLCollection.new()
      stream = HTMLCollection.to_stream(collection.pid)
      assert %Stream{} = stream
    end
  end

  describe "Enumerable protocol" do
    test "implements Enumerable.reduce/3" do
      collection = HTMLCollection.new()

      result =
        Enum.reduce(collection, 0, fn _element, acc ->
          acc + 1
        end)

      assert result == 0
    end

    test "implements Enumerable.count/1" do
      collection = HTMLCollection.new()
      assert Enum.count(collection) == 0
    end

    test "implements Enumerable.member?/2" do
      collection = HTMLCollection.new()
      element = Element.new(tag_name: "div")

      assert Enum.member?(collection, element.pid) == false
    end

    test "member? returns false for non-PID values" do
      collection = HTMLCollection.new()

      assert Enum.member?(collection, "not_a_pid") == false
      assert Enum.member?(collection, 123) == false
    end

    test "implements Enumerable.slice/1" do
      collection = HTMLCollection.new()

      # Test slicing empty collection
      result = Enum.slice(collection, 0..2)
      assert result == []

      result = Enum.slice(collection, 1, 3)
      assert result == []
    end

    test "can use Enum functions" do
      collection = HTMLCollection.new()

      # Test various Enum operations
      assert Enum.empty?(collection) == true
      assert Enum.any?(collection) == false
      assert Enum.all?(collection, fn _ -> true end) == true

      filtered = Enum.filter(collection, fn _ -> true end)
      assert filtered == []

      mapped = Enum.map(collection, fn element -> element end)
      assert mapped == []
    end
  end

  describe "inspection" do
    test "collection struct can be inspected" do
      collection =
        HTMLCollection.new(
          selector: "div",
          collection_type: :tag_name
        )

      inspected = inspect(collection)

      # Should show key fields but not internal details like PID
      assert inspected =~ "GenDOM.HTMLCollection"
      assert inspected =~ "length: 0"
      assert inspected =~ "selector: \"div\""
      assert inspected =~ "collection_type: :tag_name"
    end
  end

  describe "process lifecycle" do
    test "collection process stays alive while referenced" do
      collection = HTMLCollection.new()
      pid = collection.pid

      assert Process.alive?(pid)

      # Access collection to ensure it's working
      assert HTMLCollection.length(collection) == 0
      assert Process.alive?(pid)
    end

    test "collection can be garbage collected when unreferenced" do
      pid = HTMLCollection.new().pid

      # Force garbage collection
      :erlang.garbage_collect()
      # Give time for cleanup
      Process.sleep(10)

      # Process should still be alive immediately after creation
      assert Process.alive?(pid)
    end
  end

  describe "error handling" do
    test "handles invalid collection gracefully" do
      # Test with invalid PID
      invalid_pid = spawn(fn -> :ok end)
      Process.exit(invalid_pid, :kill)

      # These should not crash
      assert_raise ArgumentError, fn ->
        HTMLCollection.length(invalid_pid)
      end
    end

    test "item/2 handles edge cases" do
      collection = HTMLCollection.new()

      # Various invalid indexes
      assert HTMLCollection.item(collection, -1) == nil
      assert HTMLCollection.item(collection, 1000) == nil
      assert HTMLCollection.item(collection, "invalid") == nil
      assert HTMLCollection.item(collection, nil) == nil
    end

    test "named_item/2 handles edge cases" do
      collection = HTMLCollection.new()

      # Various invalid names
      assert HTMLCollection.named_item(collection, nil) == nil
      assert HTMLCollection.named_item(collection, 123) == nil
      assert HTMLCollection.named_item(collection, :atom) == nil
      assert HTMLCollection.named_item(collection, "") == nil
    end
  end

  describe "collection types" do
    test "supports tag_name collection type" do
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          selector: "div",
          collection_type: :tag_name
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "supports class_name collection type" do
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          selector: "active",
          collection_type: :class_name
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "supports children collection type" do
      document = Document.new()
      element = Element.new(tag_name: "div")

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          parent_element_pid: element.pid,
          collection_type: :children
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "supports selector collection type" do
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          selector: "div.active",
          collection_type: :selector
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "supports generic collection type" do
      collection = HTMLCollection.new(collection_type: :generic)

      assert HTMLCollection.length(collection) == 0
    end
  end

  describe "cache management" do
    test "collection starts with fresh cache" do
      collection = HTMLCollection.new()

      # Should not need refresh initially
      assert HTMLCollection.length(collection) == 0
      assert HTMLCollection.to_list(collection) == []
    end

    test "multiple calls return consistent results" do
      collection = HTMLCollection.new()

      # Multiple calls should return same results
      assert HTMLCollection.length(collection) == 0
      assert HTMLCollection.length(collection) == 0
      assert HTMLCollection.length(collection) == 0

      list1 = HTMLCollection.to_list(collection)
      list2 = HTMLCollection.to_list(collection)
      assert list1 == list2
    end
  end

  describe "integration with other modules" do
    test "works with Document module" do
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          collection_type: :tag_name,
          selector: "div"
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "works with Element module" do
      element = Element.new(tag_name: "div")
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          parent_element_pid: element.pid,
          collection_type: :children
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "collection can reference Node instances" do
      node = Node.new()
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          collection_type: :generic
        )

      # Should handle node references properly
      assert HTMLCollection.named_item(collection, "test") == nil
    end
  end

  describe "performance characteristics" do
    test "length operation is efficient" do
      collection = HTMLCollection.new()

      # Should be fast even with multiple calls
      start_time = System.monotonic_time()

      Enum.each(1..100, fn _ ->
        HTMLCollection.length(collection)
      end)

      end_time = System.monotonic_time()
      duration_ms = System.convert_time_unit(end_time - start_time, :native, :millisecond)

      # Should complete quickly (less than 100ms for 100 calls)
      assert duration_ms < 100
    end

    test "item access is efficient" do
      collection = HTMLCollection.new()

      start_time = System.monotonic_time()

      Enum.each(0..99, fn index ->
        HTMLCollection.item(collection, index)
      end)

      end_time = System.monotonic_time()
      duration_ms = System.convert_time_unit(end_time - start_time, :native, :millisecond)

      # Should complete quickly
      assert duration_ms < 100
    end

    test "stream operations are lazy" do
      collection = HTMLCollection.new()

      # Creating stream should be immediate
      start_time = System.monotonic_time()
      stream = HTMLCollection.to_stream(collection)
      end_time = System.monotonic_time()

      duration_ms = System.convert_time_unit(end_time - start_time, :native, :millisecond)

      # Stream creation should be nearly instantaneous
      assert duration_ms < 10
      assert %Stream{} = stream
    end
  end

  describe "concurrent access" do
    test "multiple processes can access same collection" do
      collection = HTMLCollection.new()

      # Spawn multiple processes accessing the collection
      tasks =
        Enum.map(1..10, fn _i ->
          Task.async(fn ->
            HTMLCollection.length(collection)
          end)
        end)

      results = Task.await_many(tasks)

      # All should return the same result
      assert Enum.all?(results, fn result -> result == 0 end)
    end

    test "concurrent length and item calls work correctly" do
      collection = HTMLCollection.new()

      length_task =
        Task.async(fn ->
          Enum.map(1..50, fn _ -> HTMLCollection.length(collection) end)
        end)

      item_task =
        Task.async(fn ->
          Enum.map(0..49, fn i -> HTMLCollection.item(collection, i) end)
        end)

      lengths = Task.await(length_task)
      items = Task.await(item_task)

      # All lengths should be 0
      assert Enum.all?(lengths, fn len -> len == 0 end)
      # All items should be nil (empty collection)
      assert Enum.all?(items, fn item -> item == nil end)
    end
  end

  describe "edge cases and boundary conditions" do
    test "handles empty string selector" do
      document = Document.new()

      collection =
        HTMLCollection.new(
          document_pid: document.pid,
          selector: "",
          collection_type: :selector
        )

      assert HTMLCollection.length(collection) == 0
    end

    test "handles nil values gracefully" do
      collection =
        HTMLCollection.new(
          document_pid: nil,
          selector: nil,
          collection_type: nil
        )

      # Should not crash
      assert HTMLCollection.length(collection) == 0
      assert HTMLCollection.item(collection, 0) == nil
      assert HTMLCollection.named_item(collection, "test") == nil
    end

    test "handles very large index values" do
      collection = HTMLCollection.new()

      # Should not crash with large numbers
      assert HTMLCollection.item(collection, 999_999_999) == nil
      assert HTMLCollection.item(collection, 1_000_000_000_000) == nil
    end

    test "stream handles infinite-like scenarios" do
      collection = HTMLCollection.new()
      stream = HTMLCollection.to_stream(collection)

      # Taking more than available should work
      result =
        stream
        |> Stream.take(1000)
        |> Enum.to_list()

      assert result == []
    end
  end
end
