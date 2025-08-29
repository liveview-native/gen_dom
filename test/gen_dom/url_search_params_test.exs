defmodule GenDOM.URLSearchParamsTest do
  use ExUnit.Case, async: true

  alias GenDOM.URLSearchParams

  describe "new/1 constructor" do
    test "creates empty URLSearchParams with no arguments" do
      params = URLSearchParams.new()
      
      assert params.size == 0
    end

    test "creates URLSearchParams from query string" do
      params = URLSearchParams.new("q=URLUtils.searchParams&topic=api")
      
      assert params.size == 2
      assert URLSearchParams.get(params, "q") == "URLUtils.searchParams"
      assert URLSearchParams.get(params, "topic") == "api"
    end

    test "creates URLSearchParams from query string with leading question mark" do
      params = URLSearchParams.new("?foo=bar&baz=qux")
      
      assert params.size == 2
      assert URLSearchParams.get(params, "foo") == "bar"
      assert URLSearchParams.get(params, "baz") == "qux"
    end

    test "creates URLSearchParams from keyword list" do
      params = URLSearchParams.new([{"foo", "bar"}, {"baz", "qux"}])
      
      assert params.size == 2
      assert URLSearchParams.get(params, "foo") == "bar"
      assert URLSearchParams.get(params, "baz") == "qux"
    end

    test "creates URLSearchParams from map" do
      params = URLSearchParams.new(%{"foo" => "bar", "baz" => "qux"})
      
      assert params.size == 2
      assert URLSearchParams.get(params, "foo") == "bar"
      assert URLSearchParams.get(params, "baz") == "qux"
    end

    test "creates URLSearchParams from another URLSearchParams instance" do
      original = URLSearchParams.new("foo=bar&baz=qux")
      copy = URLSearchParams.new(original)
      
      assert copy.size == 2
      assert URLSearchParams.get(copy, "foo") == "bar"
      assert URLSearchParams.get(copy, "baz") == "qux"
    end

    test "handles percent-encoded values during parsing" do
      params = URLSearchParams.new("name=John%20Doe&city=New%20York")
      
      assert URLSearchParams.get(params, "name") == "John Doe"
      assert URLSearchParams.get(params, "city") == "New York"
    end

    test "handles duplicate keys during parsing" do
      params = URLSearchParams.new("color=red&color=blue&color=green")
      
      assert params.size == 3
      assert URLSearchParams.get(params, "color") == "red"
      assert URLSearchParams.get_all(params, "color") == ["red", "blue", "green"]
    end

    test "handles empty values" do
      params = URLSearchParams.new("empty=&also_empty")
      
      assert params.size == 2
      assert URLSearchParams.get(params, "empty") == ""
      assert URLSearchParams.get(params, "also_empty") == ""
    end
  end

  describe "append/3" do
    test "appends new parameter" do
      params = URLSearchParams.new()
      updated = URLSearchParams.append(params, "foo", "bar")
      
      assert updated.size == 1
      assert URLSearchParams.get(updated, "foo") == "bar"
    end

    test "appends to existing parameter creating duplicates" do
      params = URLSearchParams.new("foo=bar")

      updated = URLSearchParams.append(params, "foo", "baz")
      
      assert updated.size == 2
      assert URLSearchParams.get(updated, "foo") == "bar"
      assert URLSearchParams.get_all(updated, "foo") == ["bar", "baz"]
    end

    test "preserves parameter order when appending" do
      params = URLSearchParams.new("a=1&b=2")
      updated = URLSearchParams.append(params, "c", "3")
      
      keys = URLSearchParams.keys(updated) |> Enum.to_list()
      assert keys == ["a", "b", "c"]
    end
  end

  describe "delete/2 and delete/3" do
    test "deletes all entries for specified key" do
      params = URLSearchParams.new("foo=bar&baz=qux&foo=another")
      updated = URLSearchParams.delete(params, "foo")
      
      assert updated.size == 1
      assert URLSearchParams.get(updated, "foo") == nil
      assert URLSearchParams.get(updated, "baz") == "qux"
    end

    test "deletes specific key-value pair when value provided" do
      params = URLSearchParams.new("foo=bar&foo=baz&foo=qux")
      updated = URLSearchParams.delete(params, "foo", "baz")
      
      assert updated.size == 2
      assert URLSearchParams.get_all(updated, "foo") == ["bar", "qux"]
    end

    test "does nothing when key doesn't exist" do
      params = URLSearchParams.new("foo=bar")
      updated = URLSearchParams.delete(params, "nonexistent")
      
      assert updated.size == 1
      assert URLSearchParams.get(updated, "foo") == "bar"
    end
  end

  describe "get/2" do
    test "returns first value for existing key" do
      params = URLSearchParams.new("foo=bar&foo=baz")
      
      assert URLSearchParams.get(params, "foo") == "bar"
    end

    test "returns nil for non-existing key" do
      params = URLSearchParams.new("foo=bar")
      
      assert URLSearchParams.get(params, "nonexistent") == nil
    end

    test "returns empty string for key with empty value" do
      params = URLSearchParams.new("empty=")
      
      assert URLSearchParams.get(params, "empty") == ""
    end
  end

  describe "get_all/2" do
    test "returns all values for existing key" do
      params = URLSearchParams.new("color=red&size=large&color=blue&color=green")
      
      assert URLSearchParams.get_all(params, "color") == ["red", "blue", "green"]
    end

    test "returns single-item list for key with one value" do
      params = URLSearchParams.new("foo=bar")
      
      assert URLSearchParams.get_all(params, "foo") == ["bar"]
    end

    test "returns empty list for non-existing key" do
      params = URLSearchParams.new("foo=bar")
      
      assert URLSearchParams.get_all(params, "nonexistent") == []
    end
  end

  describe "has/2 and has/3" do
    test "returns true when key exists" do
      params = URLSearchParams.new("foo=bar&baz=qux")
      
      assert URLSearchParams.has(params, "foo") == true
      assert URLSearchParams.has(params, "baz") == true
    end

    test "returns false when key doesn't exist" do
      params = URLSearchParams.new("foo=bar")
      
      assert URLSearchParams.has(params, "nonexistent") == false
    end

    test "checks for specific key-value pair when value provided" do
      params = URLSearchParams.new("foo=bar&foo=baz")
      
      assert URLSearchParams.has(params, "foo", "bar") == true
      assert URLSearchParams.has(params, "foo", "baz") == true
      assert URLSearchParams.has(params, "foo", "qux") == false
    end
  end

  describe "set/3" do
    test "sets new parameter" do
      params = URLSearchParams.new()
      updated = URLSearchParams.set(params, "foo", "bar")
      
      assert updated.size == 1
      assert URLSearchParams.get(updated, "foo") == "bar"
    end

    test "replaces all existing entries for key" do
      params = URLSearchParams.new("foo=bar&foo=baz&foo=qux")
      updated = URLSearchParams.set(params, "foo", "new_value")
      
      assert updated.size == 1
      assert URLSearchParams.get(updated, "foo") == "new_value"
      assert URLSearchParams.get_all(updated, "foo") == ["new_value"]
    end

    test "preserves other parameters when setting" do
      params = URLSearchParams.new("foo=bar&baz=qux&foo=another")
      updated = URLSearchParams.set(params, "foo", "new_value")
      
      assert updated.size == 2
      assert URLSearchParams.get(updated, "foo") == "new_value"
      assert URLSearchParams.get(updated, "baz") == "qux"
    end
  end

  describe "sort/1" do
    test "sorts parameters by key name" do
      params = URLSearchParams.new("z=last&a=first&m=middle")
      sorted = URLSearchParams.sort(params)
      
      keys = URLSearchParams.keys(sorted) |> Enum.to_list()
      assert keys == ["a", "m", "z"]
    end

    test "maintains relative order for duplicate keys after sorting" do
      params = URLSearchParams.new("z=1&a=1&z=2&a=2")
      sorted = URLSearchParams.sort(params)
      
      assert URLSearchParams.get_all(sorted, "a") == ["1", "2"]
      assert URLSearchParams.get_all(sorted, "z") == ["1", "2"]
    end

    test "sorts empty parameters without error" do
      params = URLSearchParams.new()
      sorted = URLSearchParams.sort(params)
      
      assert sorted.size == 0
    end
  end

  describe "iteration methods" do
    setup do
      params = URLSearchParams.new("foo=bar&baz=qux&foo=another")
      {:ok, params: params}
    end

    test "keys/1 returns iterator of parameter keys", %{params: params} do
      keys = URLSearchParams.keys(params) |> Enum.to_list()
      
      assert keys == ["foo", "baz", "foo"]
    end

    test "values/1 returns iterator of parameter values", %{params: params} do
      values = URLSearchParams.values(params) |> Enum.to_list()
      
      assert values == ["bar", "qux", "another"]
    end

    test "entries/1 returns iterator of key-value pairs", %{params: params} do
      entries = URLSearchParams.entries(params) |> Enum.to_list()
      
      assert entries == [{"foo", "bar"}, {"baz", "qux"}, {"foo", "another"}]
    end

    test "for_each/2 iterates over all entries", %{params: params} do
      collected = []

      URLSearchParams.for_each(params, fn(value, key) ->
        [{key, value} | collected]
      end)
      
      # Reverse because we prepended
      assert Enum.reverse(collected) == [{"foo", "bar"}, {"baz", "qux"}, {"foo", "another"}]
    end
  end

  describe "to_string/1" do
    test "converts parameters to URL-encoded string" do
      params = URLSearchParams.new("foo=bar&baz=qux")
      
      assert URLSearchParams.to_string(params) == "foo=bar&baz=qux"
    end

    test "percent-encodes special characters in output" do
      params = URLSearchParams.new()
      |> URLSearchParams.append("name", "John Doe")
      |> URLSearchParams.append("city", "New York")
      
      result = URLSearchParams.to_string(params)
      assert result == "name=John%20Doe&city=New%20York"
    end

    test "handles empty values in output" do
      params = URLSearchParams.new("empty=&also_empty")
      
      result = URLSearchParams.to_string(params)
      assert result == "empty=&also_empty="
    end

    test "maintains parameter order in output" do
      params = URLSearchParams.new("c=3&a=1&b=2")
      
      result = URLSearchParams.to_string(params)
      assert result == "c=3&a=1&b=2"
    end

    test "handles duplicate keys in output" do
      params = URLSearchParams.new("color=red&color=blue")
      
      result = URLSearchParams.to_string(params)
      assert result == "color=red&color=blue"
    end

    test "returns empty string for empty parameters" do
      params = URLSearchParams.new()
      
      assert URLSearchParams.to_string(params) == ""
    end
  end

  describe "size property" do
    test "returns 0 for empty parameters" do
      params = URLSearchParams.new()
      
      assert params.size == 0
    end

    test "returns correct count for single parameter" do
      params = URLSearchParams.new("foo=bar")
      
      assert params.size == 1
    end

    test "returns correct count including duplicates" do
      params = URLSearchParams.new("foo=bar&baz=qux&foo=another")
      
      assert params.size == 3
    end

    test "updates size after append operations" do
      params = URLSearchParams.new("foo=bar")
      updated = URLSearchParams.append(params, "baz", "qux")
      
      assert params.size == 1
      assert updated.size == 2
    end

    test "updates size after delete operations" do
      params = URLSearchParams.new("foo=bar&baz=qux&foo=another")
      updated = URLSearchParams.delete(params, "foo")
      
      assert params.size == 3
      assert updated.size == 1
    end

    test "updates size after set operations" do
      params = URLSearchParams.new("foo=bar&foo=baz&foo=qux")
      updated = URLSearchParams.set(params, "foo", "single")
      
      assert params.size == 3
      assert updated.size == 1
    end
  end

  describe "edge cases and special characters" do
    test "handles plus signs in values" do
      params = URLSearchParams.new("query=hello+world")
      
      assert URLSearchParams.get(params, "query") == "hello world"
    end

    test "handles special URL characters" do
      params = URLSearchParams.new("special=%21%40%23%24%25%5E%26%2A")
      
      assert URLSearchParams.get(params, "special") == "!@#$%^&*"
    end

    test "handles Unicode characters" do
      params = URLSearchParams.new()
      |> URLSearchParams.append("unicode", "🌟")
      |> URLSearchParams.append("chinese", "你好")
      
      assert URLSearchParams.get(params, "unicode") == "🌟"
      assert URLSearchParams.get(params, "chinese") == "你好"
    end

    test "handles equal signs in values" do
      params = URLSearchParams.new("equation=x%3D5")
      
      assert URLSearchParams.get(params, "equation") == "x=5"
    end

    test "handles ampersands in values" do
      params = URLSearchParams.new("text=rock%26roll")
      
      assert URLSearchParams.get(params, "text") == "rock&roll"
    end

    test "handles very long parameter values" do
      long_value = String.duplicate("a", 10000)
      params = URLSearchParams.new()
      |> URLSearchParams.append("long", long_value)
      
      assert URLSearchParams.get(params, "long") == long_value
    end
  end

  describe "immutability" do
    test "original params unchanged after append" do
      original = URLSearchParams.new("foo=bar")
      _updated = URLSearchParams.append(original, "baz", "qux")
      
      assert original.size == 1
      assert URLSearchParams.get(original, "baz") == nil
    end

    test "original params unchanged after delete" do
      original = URLSearchParams.new("foo=bar&baz=qux")
      _updated = URLSearchParams.delete(original, "foo")
      
      assert original.size == 2
      assert URLSearchParams.get(original, "foo") == "bar"
    end

    test "original params unchanged after set" do
      original = URLSearchParams.new("foo=bar")
      _updated = URLSearchParams.set(original, "foo", "changed")
      
      assert URLSearchParams.get(original, "foo") == "bar"
    end

    test "original params unchanged after sort" do
      original = URLSearchParams.new("z=1&a=2")
      _sorted = URLSearchParams.sort(original)
      
      keys = URLSearchParams.keys(original) |> Enum.to_list()
      assert keys == ["z", "a"]
    end
  end
end
