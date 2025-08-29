defmodule GenDOM.URLSearchParams do
  @moduledoc """
  The URLSearchParams interface provides utilities for working with URL query strings.

  The URLSearchParams interface defines utilities for working with the query string of a URL.
  It provides methods to parse, manipulate, and format URL search parameters in a convenient way.

  ## Specification Compliance

  This module implements the URLSearchParams interface as defined by:
  - **WHATWG URL Standard**: https://url.spec.whatwg.org/#urlsearchparams
  - **MDN Web Docs**: https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams
  - **HTML Standard**: https://html.spec.whatwg.org/multipage/

  ## Properties

  ### Search Parameters Management
  - `size` - The number of search parameter name-value pairs (read-only)

  ## Constructor Options

  URLSearchParams can be created from various sources:
  - Empty (no parameters)
  - String (query string format)
  - Map or keyword list of parameters
  - Another URLSearchParams instance

  ## Methods

  ### Parameter Manipulation
  - `new/0`, `new/1` - Create a new URLSearchParams object
  - `append/3` - Append a name-value pair
  - `set/3` - Set a name-value pair (replacing existing)
  - `delete/2`, `delete/3` - Remove parameters by name or name-value pair
  - `sort/1` - Sort parameters alphabetically by name

  ### Parameter Access
  - `get/2` - Get the first value for a parameter name
  - `get_all/2` - Get all values for a parameter name
  - `has/2`, `has/3` - Check if parameter exists
  - `keys/1` - Get iterator over parameter names
  - `values/1` - Get iterator over parameter values
  - `entries/1` - Get iterator over name-value pairs

  ### Iteration and Processing
  - `for_each/2`, `for_each/3` - Execute callback for each parameter

  ### Serialization
  - `to_string/1` - Convert to query string format

  ## Creating URLSearchParams

  Various ways to create URLSearchParams objects:

  ```elixir
  # Empty parameters
  params = GenDOM.URLSearchParams.new()

  # From query string
  params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")

  # From keyword list
  params = GenDOM.URLSearchParams.new([
    {"name", "John"}, 
    {"age", "30"}, 
    {"hobby", "reading"}, 
    {"hobby", "coding"}
  ])

  # From map (single values)
  params = GenDOM.URLSearchParams.new(%{
    "name" => "John",
    "age" => "30",
    "city" => "New York"
  })

  # Copy from another URLSearchParams
  original = GenDOM.URLSearchParams.new("name=John&age=30")
  copy = GenDOM.URLSearchParams.new(original)
  ```

  ## Parameter Manipulation

  Add, update, and remove parameters:

  ```elixir
  params = GenDOM.URLSearchParams.new()

  # Add parameters (append allows duplicates)
  params = GenDOM.URLSearchParams.append(params, "hobby", "reading")
  params = GenDOM.URLSearchParams.append(params, "hobby", "coding")  # Multiple values

  # Set parameters (replaces existing)
  params = GenDOM.URLSearchParams.set(params, "name", "John")
  params = GenDOM.URLSearchParams.set(params, "age", "30")

  # Delete parameters
  params = GenDOM.URLSearchParams.delete(params, "age")  # Remove all "age" parameters
  params = GenDOM.URLSearchParams.delete(params, "hobby", "reading")  # Remove specific value
  ```

  ## Parameter Access

  Retrieve parameter values:

  ```elixir
  params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")

  # Get first value for a parameter
  name = GenDOM.URLSearchParams.get(params, "name")  # "John"
  hobby = GenDOM.URLSearchParams.get(params, "hobby")  # "reading"

  # Get all values for a parameter
  all_hobbies = GenDOM.URLSearchParams.get_all(params, "hobby")  # ["reading", "coding"]

  # Check if parameter exists
  has_name = GenDOM.URLSearchParams.has(params, "name")  # true
  has_email = GenDOM.URLSearchParams.has(params, "email")  # false
  has_specific_hobby = GenDOM.URLSearchParams.has(params, "hobby", "coding")  # true
  ```

  ## Iteration

  Iterate over parameters:

  ```elixir
  params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")

  # Iterate over all name-value pairs
  GenDOM.URLSearchParams.for_each(params, fn name, value ->
    IO.puts("\#{name}: \#{value}")
  end)

  # Get iterators (when implemented)
  keys = GenDOM.URLSearchParams.keys(params)       # ["name", "age", "hobby", "hobby"]
  values = GenDOM.URLSearchParams.values(params)   # ["John", "30", "reading", "coding"]
  entries = GenDOM.URLSearchParams.entries(params) # [{"name", "John"}, {"age", "30"}, ...]
  ```

  ## Sorting and Formatting

  Sort parameters and convert to strings:

  ```elixir
  params = GenDOM.URLSearchParams.new("hobby=reading&name=John&age=30&hobby=coding")

  # Sort parameters alphabetically by name
  sorted_params = GenDOM.URLSearchParams.sort(params)

  # Convert to query string
  query_string = GenDOM.URLSearchParams.to_string(sorted_params)
  # Result: "age=30&hobby=reading&hobby=coding&name=John"
  ```

  ## Form Data Integration

  Work with form data:

  ```elixir
  # Create from form fields
  form_params = GenDOM.URLSearchParams.new([
    {"username", "john_doe"},
    {"password", "secret123"},
    {"remember", "on"},
    {"interests", "programming"},
    {"interests", "music"}
  ])

  # Convert to query string for form submission
  form_data = GenDOM.URLSearchParams.to_string(form_params)
  # Result: "username=john_doe&password=secret123&remember=on&interests=programming&interests=music"
  ```

  ## URL Integration

  Use with URL objects:

  ```elixir
  # Extract from URL
  url = GenDOM.URL.new("https://example.com/search?q=elixir&type=docs&page=1")
  params = GenDOM.URLSearchParams.new(url.search)

  # Modify parameters
  params = GenDOM.URLSearchParams.set(params, "page", "2")
  params = GenDOM.URLSearchParams.append(params, "filter", "recent")

  # Update URL with modified parameters
  updated_search = GenDOM.URLSearchParams.to_string(params)
  updated_url = %{url | search: "?" <> updated_search}
  ```

  ## Special Characters and Encoding

  Handle special characters properly:

  ```elixir
  # Special characters are automatically encoded
  params = GenDOM.URLSearchParams.new()
  params = GenDOM.URLSearchParams.set(params, "message", "Hello, World! 🌍")
  params = GenDOM.URLSearchParams.set(params, "redirect", "https://example.com/page?id=123")

  query_string = GenDOM.URLSearchParams.to_string(params)
  # Result: "message=Hello%2C%20World%21%20%F0%9F%8C%8D&redirect=https%3A%2F%2Fexample.com%2Fpage%3Fid%3D123"
  ```

  ## Array and Object Parameters

  Handle array-like parameters:

  ```elixir
  # Multiple values for the same parameter
  params = GenDOM.URLSearchParams.new()
  params = GenDOM.URLSearchParams.append(params, "tags[]", "javascript")
  params = GenDOM.URLSearchParams.append(params, "tags[]", "elixir")
  params = GenDOM.URLSearchParams.append(params, "tags[]", "phoenix")

  # Get all tag values
  all_tags = GenDOM.URLSearchParams.get_all(params, "tags[]")
  # Result: ["javascript", "elixir", "phoenix"]
  ```

  ## Search and Filter Operations

  Common search parameter patterns:

  ```elixir
  # Search with filters
  search_params = GenDOM.URLSearchParams.new([
    {"q", "elixir programming"},
    {"category", "tutorials"},
    {"difficulty", "beginner"},
    {"sort", "newest"},
    {"per_page", "20"},
    {"page", "1"}
  ])

  # Pagination
  next_page = GenDOM.URLSearchParams.set(search_params, "page", "2")

  # Apply additional filters
  advanced_search = GenDOM.URLSearchParams.append(next_page, "tag", "phoenix")
  advanced_search = GenDOM.URLSearchParams.append(advanced_search, "tag", "liveview")
  ```

  ## Browser Compatibility

  URLSearchParams provides a consistent interface across different environments and follows
  the standard Web API behavior for parameter handling and encoding.

  ## Performance Characteristics

  - **Creation**: O(n) where n is the number of parameters
  - **Parameter Access**: O(1) for single values, O(k) for multiple values where k is value count
  - **Parameter Modification**: O(1) for set/append, O(n) for delete operations
  - **Sorting**: O(n log n) where n is number of parameters
  - **String Serialization**: O(n) where n is total parameter data size

  ## Common Patterns

  ### API Query Building
  ```elixir
  # Build API query parameters
  api_params = GenDOM.URLSearchParams.new()
  api_params = GenDOM.URLSearchParams.set(api_params, "api_key", api_key)
  api_params = GenDOM.URLSearchParams.set(api_params, "format", "json")
  api_params = GenDOM.URLSearchParams.set(api_params, "limit", "50")

  api_url = "https://api.example.com/data?" <> GenDOM.URLSearchParams.to_string(api_params)
  ```

  ### Form Serialization
  ```elixir
  # Serialize form data
  form_data = GenDOM.URLSearchParams.new([
    {"first_name", "John"},
    {"last_name", "Doe"},
    {"email", "john@example.com"},
    {"newsletter", "on"}
  ])

  post_body = GenDOM.URLSearchParams.to_string(form_data)
  ```

  ### Query String Parsing
  ```elixir
  # Parse existing query string
  query = "?name=John&interests=coding&interests=music&age=30"
  params = GenDOM.URLSearchParams.new(String.trim_leading(query, "?"))

  # Extract specific information
  name = GenDOM.URLSearchParams.get(params, "name")
  interests = GenDOM.URLSearchParams.get_all(params, "interests")
  ```

  ## Error Handling

  Parameter operations handle edge cases gracefully:

  ```elixir
  params = GenDOM.URLSearchParams.new("name=John&age=30")

  # Getting non-existent parameters
  missing = GenDOM.URLSearchParams.get(params, "email")  # nil or empty string

  # Deleting non-existent parameters (no error)
  params = GenDOM.URLSearchParams.delete(params, "email")

  # Invalid parameter names are typically allowed but may be encoded
  params = GenDOM.URLSearchParams.set(params, "", "empty_name")
  ```

  ## Integration with Web APIs

  URLSearchParams integrates with other Web APIs:

  ```elixir
  # With Fetch API for POST requests
  form_params = GenDOM.URLSearchParams.new([
    {"username", "john"},
    {"password", "secret"}
  ])

  request = GenDOM.Request.new("/login", [
    method: "POST",
    headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
    body: GenDOM.URLSearchParams.to_string(form_params)
  ])
  ```
  """

  @derive {Inspect, only: [:size]}

  defstruct [
    # Number of search parameter name-value pairs (read-only)
    size: 0,
    entries: %{}
  ]

  @doc """
  Creates a new URLSearchParams object.

  The URLSearchParams() constructor creates and returns a new URLSearchParams object.
  Leading '?' characters are ignored.

  ## Parameters

  - `query` - Optional initialization data:
    - Empty list `[]` - Create empty parameters
    - String - Parse query string (e.g., "name=John&age=30")
    - List of tuples - Parameter name-value pairs
    - Map - Convert map to parameters
    - Another URLSearchParams - Copy parameters

  ## Returns

  A new `%GenDOM.URLSearchParams{}` struct.

  ## Examples

      # Empty parameters
      params = GenDOM.URLSearchParams.new()
      
      # From query string
      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading")
      
      # From list of tuples
      params = GenDOM.URLSearchParams.new([
        {"name", "John"}, 
        {"age", "30"}, 
        {"hobby", "reading"}
      ])
      
      # From map
      params = GenDOM.URLSearchParams.new(%{"name" => "John", "age" => "30"})
      
      # Copy from another URLSearchParams
      copy = GenDOM.URLSearchParams.new(existing_params)

  ## Web API Reference

  [MDN Web Docs: URLSearchParams() constructor](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/URLSearchParams)
  """
  def new do
    new([])
  end

  def new(%__MODULE__{entries: entries}) do
    new(entries)
  end

  def new(<<"?"::utf8, query_string::binary>>) do
    new(query_string)
  end

  def new(query_string) when is_binary(query_string) do
    query_string
    |> URI.query_decoder()
    |> Enum.to_list()
    |> new()
  end

  def new(query_map) when is_map(query_map) do
    new(Map.to_list(query_map))
  end

  def new(query_pairs) when is_list(query_pairs) do
    %__MODULE__{
      entries: query_pairs,
      size: length(query_pairs)
    }
  end

  @doc """
  Appends a name-value pair to the search parameters.

  The append() method appends a specified key/value pair as a new search parameter.
  If the same key is appended multiple times, it will appear multiple times in the parameter list.

  ## Parameters

  - `params` - The URLSearchParams struct to modify
  - `name` - String name of the parameter
  - `value` - String value of the parameter

  ## Returns

  A new `%GenDOM.URLSearchParams{}` struct with the parameter appended.

  ## Examples

      params = GenDOM.URLSearchParams.new()
      params = GenDOM.URLSearchParams.append(params, "hobby", "reading")
      params = GenDOM.URLSearchParams.append(params, "hobby", "coding")
      
      # Result: "hobby=reading&hobby=coding"
      GenDOM.URLSearchParams.to_string(params)

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.append()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/append)
  """
  def append(%__MODULE__{entries: entries, size: size} = params, name, value) do
    entries = List.insert_at(entries, -1, {name, value})
    Map.merge(params, %{entries: entries, size: length(entries)})
  end

  @doc """
  Deletes search parameters by name or name-value pair.

  The delete() method deletes search parameters and their values from the list of all search parameters.
  If a value is provided, only parameters with that exact name-value pair are deleted.

  ## Parameters

  - `params` - The URLSearchParams struct to modify
  - `name` - String name of the parameter(s) to delete
  - `value` - Optional string value to match (if nil, all parameters with the name are deleted)

  ## Returns

  A new `%GenDOM.URLSearchParams{}` struct with the specified parameter(s) removed.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      
      # Delete all parameters with name "hobby"
      params = GenDOM.URLSearchParams.delete(params, "hobby")
      # Result: "name=John&age=30"
      
      # Delete only specific name-value pair
      params = GenDOM.URLSearchParams.delete(params, "hobby", "reading")
      # Result: "name=John&age=30&hobby=coding"

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.delete()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/delete)
  """
  def delete(%__MODULE__{entries: entries, size: size} = params, name) do
    entries =
      Enum.reject(entries, fn
        {^name, _value} -> true
        _entry -> false
      end)

    Map.merge(params, %{entries: entries, size: length(entries)})
  end

  def delete(%__MODULE__{entries: entries, size: size} = params, name, value) do
    entries =
      Enum.reject(entries, fn
        {^name, ^value} -> true
        _entry -> false
      end)

    Map.merge(params, %{entries: entries, size: length(entries)})
  end

  @doc """
  Returns an iterator over all name-value pairs.

  The entries() method returns an iterator allowing iteration through all key/value pairs contained in this object.

  ## Parameters

  - `params` - The URLSearchParams struct to iterate over

  ## Returns

  A list of `{name, value}` tuples representing all parameters.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      entries = GenDOM.URLSearchParams.entries(params)
      # Result: [{"name", "John"}, {"age", "30"}, {"hobby", "reading"}, {"hobby", "coding"}]

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.entries()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/entries)
  """
  def entries(%__MODULE__{entries: entries} = params) do
    entries
  end

  @doc """
  Executes a callback function for each name-value pair.

  The forEach() method executes a provided function once for each key/value pair in the URLSearchParams object.

  ## Parameters

  - `params` - The URLSearchParams struct to iterate over
  - `callback` - Function to execute for each parameter (receives value, name, searchParams)
  - `this` - Optional context value (not commonly used in Elixir)

  ## Returns

  `:ok` (forEach returns undefined in JavaScript).

  ## Examples

      params = GenDOM.URLSearchParams.new("foo=1&bar=2&foo=3")
      
      GenDOM.URLSearchParams.for_each(params, fn value, name, _params ->
        IO.puts("\#{name}: \#{value}")
      end)
      # Outputs:
      # foo: 1
      # bar: 2
      # foo: 3

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.forEach()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/forEach)
  """
  def for_each(%__MODULE__{entries: entries}, callback) when is_function(callback, 2) do
    Enum.each(entries, fn {name, value} ->
      callback.(value, name)
    end)

    # forEach returns undefined in JavaScript
    :ok
  end

  def for_each(%__MODULE__{entries: entries}, callback) when is_function(callback, 2) do
    # Allow callback with just 2 args (value, name)
    for_each(entries, fn({value, name}) -> callback.(value, name) end)
  end

  @doc """
  Returns the first value associated with the given search parameter.

  The get() method returns the first value associated with the given search parameter name.

  ## Parameters

  - `params` - The URLSearchParams struct to search
  - `name` - String name of the parameter to retrieve

  ## Returns

  A string value of the parameter, or `nil` if the parameter is not found.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      
      name = GenDOM.URLSearchParams.get(params, "name")      # "John"
      age = GenDOM.URLSearchParams.get(params, "age")        # "30"
      hobby = GenDOM.URLSearchParams.get(params, "hobby")    # "reading" (first value)
      missing = GenDOM.URLSearchParams.get(params, "email")  # nil

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.get()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/get)
  """
  def get(%__MODULE__{entries: entries}, name) do
    Enum.find_value(entries, fn
      {^name, value} -> value
      _other -> false
    end)
  end

  @doc """
  Returns all values associated with the given search parameter.

  The getAll() method returns all values associated with a given search parameter name as an array.

  ## Parameters

  - `params` - The URLSearchParams struct to search
  - `name` - String name of the parameter to retrieve

  ## Returns

  A list of string values for the parameter, or empty list if parameter is not found.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      
      hobbies = GenDOM.URLSearchParams.get_all(params, "hobby")  # ["reading", "coding"]
      names = GenDOM.URLSearchParams.get_all(params, "name")     # ["John"]
      missing = GenDOM.URLSearchParams.get_all(params, "email") # []

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.getAll()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/getAll)
  """
  def get_all(%__MODULE__{entries: entries}, name) do
    Enum.reduce(entries, [], fn
      {^name, value}, acc -> [value | acc]
      _other, acc -> acc
    end)
    |> Enum.reverse()
  end

  @doc """
  Returns whether a search parameter exists.

  The has() method returns a boolean indicating whether such a parameter exists.
  If value is provided, checks for the specific name-value pair.

  ## Parameters

  - `params` - The URLSearchParams struct to search
  - `name` - String name of the parameter to check
  - `value` - Optional string value to match (if nil, checks only name existence)

  ## Returns

  `true` if the parameter exists (with optional value match), `false` otherwise.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      
      GenDOM.URLSearchParams.has(params, "name")              # true
      GenDOM.URLSearchParams.has(params, "email")             # false
      GenDOM.URLSearchParams.has(params, "hobby", "reading")  # true
      GenDOM.URLSearchParams.has(params, "hobby", "music")    # false

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.has()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/has)
  """
  def has(%__MODULE__{entries: entries}, name) do
    Enum.any?(entries, fn
      {^name, _value} -> true
      _entry -> false
    end)
  end

  def has(%__MODULE__{entries: entries}, name, value) do
    Enum.any?(entries, fn
      {^name, ^value} -> true
      _entry -> false
    end)
  end

  @doc """
  Returns an iterator over all parameter names.

  The keys() method returns an iterator allowing iteration through all keys contained in this object.

  ## Parameters

  - `params` - The URLSearchParams struct to get keys from

  ## Returns

  A list of string parameter names.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      keys = GenDOM.URLSearchParams.keys(params)
      # Result: ["name", "age", "hobby", "hobby"]

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.keys()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/keys)
  """
  def keys(%__MODULE__{entries: entries}) do
    Enum.map(entries, fn {name, _value} -> name end)
  end

  @doc """
  Sets a name-value pair, replacing any existing parameters with the same name.

  The set() method sets the value associated with a given search parameter name.
  If there were several values, this method deletes the others.

  ## Parameters

  - `params` - The URLSearchParams struct to modify
  - `name` - String name of the parameter
  - `value` - String value of the parameter

  ## Returns

  A new `%GenDOM.URLSearchParams{}` struct with the parameter set.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&hobby=reading&hobby=coding")
      
      # Set new parameter
      params = GenDOM.URLSearchParams.set(params, "age", "30")
      # Result: "name=John&hobby=reading&hobby=coding&age=30"
      
      # Replace existing parameter (removes all existing values)
      params = GenDOM.URLSearchParams.set(params, "hobby", "music")
      # Result: "name=John&age=30&hobby=music"

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.set()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/set)
  """
  def set(%__MODULE__{entries: entries, size: size} = params, name, value) do
    entries =
      Enum.reduce(entries, {[], false}, fn
        {^name, _value}, {acc, false} -> {[{name, value} | acc], true}
        {^name, _value}, {acc, true} -> {acc, true}
        entry, {acc, found?} -> {[entry | acc], found?}
      end)
      |> case do
        {entries, true} -> entries
        {entries, false} -> [{name, value} | entries]
      end
      |> Enum.reverse()

    Map.merge(params, %{entries: entries, size: length(entries)})
  end

  @doc """
  Sorts all name-value pairs by name.

  The sort() method sorts all key/value pairs contained in this object in place and returns undefined.
  The sort order is according to Unicode code points of the keys.

  ## Parameters

  - `params` - The URLSearchParams struct to sort

  ## Returns

  A new `%GenDOM.URLSearchParams{}` struct with parameters sorted by name.

  ## Examples

      params = GenDOM.URLSearchParams.new("hobby=reading&name=John&age=30&hobby=coding")
      sorted_params = GenDOM.URLSearchParams.sort(params)
      
      result = GenDOM.URLSearchParams.to_string(sorted_params)
      # Result: "age=30&hobby=reading&hobby=coding&name=John"

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.sort()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/sort)
  """
  def sort(%__MODULE__{entries: entries} = params) do
    entries = Enum.sort_by(entries, fn {name, _value} -> name end)

    Map.merge(params, %{entries: entries})
  end

  @doc """
  Returns the search parameters as a query string.

  The toString() method returns a query string suitable for use in a URL.

  ## Parameters

  - `params` - The URLSearchParams struct to serialize

  ## Returns

  A string representing the search parameters in query string format.

  ## Examples

      params = GenDOM.URLSearchParams.new([
        {"name", "John Doe"},
        {"age", "30"},
        {"hobby", "reading"},
        {"hobby", "coding"}
      ])
      
      query_string = GenDOM.URLSearchParams.to_string(params)
      # Result: "name=John+Doe&age=30&hobby=reading&hobby=coding"

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.toString()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/toString)
  """
  def to_string(%__MODULE__{entries: entries}) do
    URI.encode_query(entries, :rfc3986)
  end

  @doc """
  Returns an iterator over all parameter values.

  The values() method returns an iterator allowing iteration through all values contained in this object.

  ## Parameters

  - `params` - The URLSearchParams struct to get values from

  ## Returns

  A list of string parameter values.

  ## Examples

      params = GenDOM.URLSearchParams.new("name=John&age=30&hobby=reading&hobby=coding")
      values = GenDOM.URLSearchParams.values(params)
      # Result: ["John", "30", "reading", "coding"]

  ## Web API Reference

  [MDN Web Docs: URLSearchParams.values()](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams/values)
  """
  def values(%__MODULE__{entries: entries} = params) do
    Enum.map(entries, fn {_name, value} -> value end)
  end
end
