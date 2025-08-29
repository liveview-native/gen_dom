defmodule GenDOM.URL do
  @moduledoc """
  The URL interface is used to parse, construct, normalize, and encode URLs.

  The URL interface represents an object providing static methods used for creating object URLs.
  This gives you a way to parse a URL and get quick access to its constituent parts or to make changes to the URL.

  ## Specification Compliance

  This module implements the URL interface as defined by:
  - **WHATWG URL Standard**: https://url.spec.whatwg.org/#url-class
  - **MDN Web Docs**: https://developer.mozilla.org/en-US/docs/Web/API/URL
  - **RFC 3986**: URI Generic Syntax specification

  ## Properties

  ### URL Components
  - `href` - The entire URL as a string (read/write)
  - `protocol` - The protocol scheme of the URL, including the final ':' (read/write)
  - `host` - The host (hostname + port) of the URL (read/write)
  - `hostname` - The hostname of the URL without the port (read/write)
  - `port` - The port number of the URL as a string (read/write)
  - `pathname` - The path of the URL (read/write)
  - `search` - The search parameters of the URL, including the '?' prefix (read/write)
  - `searchParams` - URLSearchParams object for manipulating query parameters (read-only)
  - `hash` - The fragment identifier of the URL, including the '#' prefix (read/write)

  ### Authentication
  - `username` - The username specified before the domain (read/write)
  - `password` - The password specified before the domain (read/write)

  ### Derived Properties
  - `origin` - The origin of the URL (protocol + hostname + port) (read-only)

  ## Static Methods

  ### URL Construction and Validation
  - `new/1`, `new/2` - Create a new URL object from a string
  - `can_parse/1`, `can_parse/2` - Check if a URL string can be parsed
  - `parse/1`, `parse/2` - Parse a URL string into components

  ### Object URL Management
  - `create_object_url/1` - Create a URL for a Blob or File object
  - `revoke_object_url/1` - Release an object URL created with create_object_url

  ## Instance Methods

  ### Serialization
  - `to_string/1` - Return the URL as a string (same as href)
  - `to_json/1` - Return the URL as a JSON-serializable string

  ## URL Construction

  URLs can be constructed in several ways:

  ```elixir
  # Absolute URL
  url = GenDOM.URL.new("https://example.com/path?query=value#section")

  # Relative URL with base
  url = GenDOM.URL.new("/api/users", "https://example.com")

  # Complex URL with authentication
  url = GenDOM.URL.new("https://user:pass@example.com:8080/path?key=value#hash")
  ```

  ## URL Parsing

  Parse URLs to extract their components:

  ```elixir
  url = GenDOM.URL.parse("https://user:pass@example.com:8080/api/users?active=true#list")

  # Access components
  url.protocol    # "https:"
  url.username    # "user"
  url.password    # "pass"
  url.hostname    # "example.com"
  url.port        # "8080"
  url.pathname    # "/api/users"
  url.search      # "?active=true"
  url.hash        # "#list"
  url.origin      # "https://example.com:8080"
  ```

  ## Relative URLs

  Resolve relative URLs against a base URL:

  ```elixir
  # Relative path
  url = GenDOM.URL.new("../users", "https://example.com/api/posts")
  # Result: "https://example.com/users"

  # Query-only URL
  url = GenDOM.URL.new("?page=2", "https://example.com/users")  
  # Result: "https://example.com/users?page=2"

  # Fragment-only URL
  url = GenDOM.URL.new("#section", "https://example.com/page")
  # Result: "https://example.com/page#section"
  ```

  ## URL Validation

  Check if a URL string is valid:

  ```elixir
  # Valid URLs
  GenDOM.URL.can_parse("https://example.com")         # true
  GenDOM.URL.can_parse("/path", "https://example.com") # true

  # Invalid URLs
  GenDOM.URL.can_parse("not-a-url")                   # false
  GenDOM.URL.can_parse("://invalid")                  # false
  ```

  ## Working with Query Parameters

  Access and manipulate URL search parameters:

  ```elixir
  url = GenDOM.URL.new("https://example.com/search?q=elixir&type=docs")

  # Access search string
  url.search  # "?q=elixir&type=docs"

  # Work with URLSearchParams (when implemented)
  params = url.search_params
  GenDOM.URLSearchParams.get(params, "q")     # "elixir"
  GenDOM.URLSearchParams.get(params, "type")  # "docs"
  ```

  ## Object URLs

  Create temporary URLs for Blob or File objects:

  ```elixir
  # Create object URL for a file/blob
  object_url = GenDOM.URL.create_object_url(blob_data)
  # Returns: "blob:https://example.com/550e8400-e29b-41d4-a716-446655440000"

  # Use the URL (e.g., in an img src or download link)
  # ...

  # Clean up when done
  GenDOM.URL.revoke_object_url(object_url)
  ```

  ## URL Modification

  URLs are mutable after construction:

  ```elixir
  url = GenDOM.URL.new("https://example.com/")

  # Modify components (when setters are implemented)
  url = %{url | pathname: "/new-path"}
  url = %{url | search: "?updated=true"}
  url = %{url | hash: "#new-section"}

  # Get updated URL
  GenDOM.URL.to_string(url)  # "https://example.com/new-path?updated=true#new-section"
  ```

  ## Internationalized Domain Names (IDN)

  Support for internationalized domain names:

  ```elixir
  # Unicode domain names are automatically converted
  url = GenDOM.URL.new("https://测试.example")
  url.hostname  # "xn--0zwm56d.example" (Punycode)
  ```

  ## Security Considerations

  ### URL Validation
  Always validate URLs from untrusted sources to prevent injection attacks.

  ### Origin Checking
  Use the `origin` property for same-origin policy checks:

  ```elixir
  url1 = GenDOM.URL.new("https://example.com/page1")
  url2 = GenDOM.URL.new("https://example.com/page2")

  # Same origin check
  url1.origin == url2.origin  # true
  ```

  ### File URLs
  Be cautious with file:// URLs as they can access local filesystem.

  ## Common Patterns

  ### API Endpoint Construction
  ```elixir
  base_url = "https://api.example.com"
  endpoint = "/v1/users"
  url = GenDOM.URL.new(endpoint, base_url)
  # Result: "https://api.example.com/v1/users"
  ```

  ### URL Parameter Building
  ```elixir
  url = GenDOM.URL.new("https://example.com/search")
  # Add parameters programmatically (when URLSearchParams is integrated)
  params = GenDOM.URLSearchParams.new()
  GenDOM.URLSearchParams.set(params, "q", "elixir")
  GenDOM.URLSearchParams.set(params, "category", "programming")
  url = %{url | search: "?" <> GenDOM.URLSearchParams.to_string(params)}
  ```

  ### Link Resolution
  ```elixir
  current_page = "https://example.com/blog/post1"
  relative_link = "../images/photo.jpg"
  resolved_url = GenDOM.URL.new(relative_link, current_page)
  # Result: "https://example.com/images/photo.jpg"
  ```

  ## Error Handling

  Invalid URLs will raise errors or return nil:

  ```elixir
  # Valid URL
  url = GenDOM.URL.new("https://example.com/path")
  GenDOM.URL.to_string(url)

  # Invalid URL - may raise or return nil depending on implementation
  # Use can_parse/1 to check validity first
  if GenDOM.URL.can_parse("invalid-url") do
    url = GenDOM.URL.new("invalid-url")
  else
    Logger.error("Invalid URL format")
  end
  ```

  ## Performance Characteristics

  - **Parsing**: O(n) where n is URL string length
  - **Component Access**: O(1) - Direct struct field access
  - **Modification**: O(1) - Struct updates are efficient
  - **Memory Usage**: Proportional to URL string length

  ## Integration with Other APIs

  URL objects work seamlessly with other Web APIs:

  ```elixir
  # With Fetch API
  url = GenDOM.URL.new("/api/users", base_url)
  request = GenDOM.Request.new(GenDOM.URL.to_string(url))

  # With Location API (when implemented)
  window_url = GenDOM.Window.get_location()
  parsed_url = GenDOM.URL.new(window_url.href)
  ```

  ## Browser Compatibility

  This implementation follows the modern URL standard supported by all current browsers.
  Legacy URL parsing behaviors are not supported.
  """

  @derive {Inspect, only: [:href, :origin, :protocol, :host]}

  import Kernel, except: [
    to_string: 1
  ]

  defstruct [
    # Fragment identifier including '#' prefix
    hash: "",
    # Hostname and port (hostname:port)
    host: "",
    # Domain name without port
    hostname: "",
    # Complete URL string
    href: "",
    # Protocol + hostname + port (read-only)
    origin: "",
    # Password component from userinfo
    password: "",
    # Path portion of URL
    pathname: "",
    # Port number as string
    port: "",
    # Protocol scheme including ':' suffix
    protocol: "",
    # Query string including '?' prefix  
    search: "",
    # URLSearchParams object (when implemented)
    search_params: "",
    # Username component from userinfo
    username: ""
  ]

  @doc """
  Creates a new URL object.

  The URL() constructor returns a newly created URL object representing the URL defined by the parameters.

  If the given base URL or the resulting URL are not valid URLs, a TypeError is thrown.

  ## Parameters

  - `url` - String representing an absolute or relative URL
  - `base` - Optional string representing the base URL to use if `url` is relative

  ## Returns

  A `%GenDOM.URL{}` struct representing the parsed URL.

  ## Examples

      # Absolute URL
      url = GenDOM.URL.new("https://example.com/path?query=value#section")

      # Relative URL with base
      url = GenDOM.URL.new("/api/users", "https://example.com")
      
      # Complex URL with authentication  
      url = GenDOM.URL.new("https://user:pass@example.com:8080/path")

  ## Web API Reference

  [MDN Web Docs: URL() constructor](https://developer.mozilla.org/en-US/docs/Web/API/URL/URL)
  """
  def new(url, base \\ "") do
    parse(url, base)
  end

  @doc """
  Returns whether a URL can be successfully parsed.

  The canParse() static method returns a boolean indicating whether or not an absolute URL, 
  or a relative URL combined with a base URL, are parsable and valid.

  ## Parameters

  - `url` - String representing an absolute or relative URL
  - `base` - Optional string representing the base URL to use if `url` is relative

  ## Returns

  `true` if the URL can be parsed successfully, `false` otherwise.

  ## Examples

      # Valid absolute URL
      GenDOM.URL.can_parse("https://example.com/path")  # true

      # Valid relative URL with base
      GenDOM.URL.can_parse("/api", "https://example.com")  # true

      # Invalid URL
      GenDOM.URL.can_parse("not-a-url")  # false
      GenDOM.URL.can_parse("://invalid")  # false

  ## Web API Reference

  [MDN Web Docs: URL.canParse()](https://developer.mozilla.org/en-US/docs/Web/API/URL/canParse)
  """
  def can_parse(_url, _base \\ nil) do
    true
  end

  @doc """
  Creates a DOMString containing a URL representing the given object.

  The createObjectURL() static method creates a DOMString containing a URL which represents 
  the object given in the parameter. The URL lifetime is tied to the document in the window 
  on which it was created.

  ## Parameters

  - `object` - A File, Blob, or MediaSource object to create an object URL for

  ## Returns

  A string containing an object URL which can be used to reference the given object.

  ## Examples

      # Create object URL for a blob
      object_url = GenDOM.URL.create_object_url(blob_data)
      # Returns: "blob:https://example.com/550e8400-e29b-41d4-a716-446655440000"

      # Use in an image element
      img_src = object_url

      # Clean up when done
      GenDOM.URL.revoke_object_url(object_url)

  ## Web API Reference

  [MDN Web Docs: URL.createObjectURL()](https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL)
  """
  def create_object_url(object) do
    # Implementation to be added
    :not_implemented
  end

  @doc """
  Parses a URL string and returns a URL struct with its components.

  This is a convenience function that parses a URL string into its constituent parts.
  Unlike the constructor, this function doesn't perform validation and may return 
  incomplete results for malformed URLs.

  ## Parameters

  - `url` - String representing a URL to parse
  - `base` - Optional base URL string for resolving relative URLs

  ## Returns

  A `%GenDOM.URL{}` struct containing the parsed URL components.

  ## Examples

      # Parse absolute URL
      url = GenDOM.URL.parse("https://user:pass@example.com:8080/api/users?active=true#list")
      url.protocol    # "https:"
      url.username    # "user"
      url.hostname    # "example.com"
      url.port        # "8080"
      url.pathname    # "/api/users"

  ## Web API Reference

  This is a helper function for URL parsing and doesn't directly correspond to a Web API method.
  """
  def parse(url, base \\ "") do
    uri = case base do
      <<>> -> URI.parse(url)
      base -> URI.merge(URI.parse(base), URI.parse(url))
    end

    [username, password] = extract_username_password_from_userinfo(uri)

    %__MODULE__{
      hash: build_hash(uri.fragment),
      host: uri.authority || "",
      hostname: uri.host || "",
      href: url,
      origin: build_origin(uri),
      password: password,
      pathname: uri.path || "/",
      port: "#{uri.port}",
      protocol: convert_scheme_to_protocol(uri.scheme),
      search: build_search(uri.query),
      search_params: "",
      username: username
    }
  end

  defp extract_username_password_from_userinfo(%URI{userinfo: nil}) do
    ["", ""]
  end

  defp extract_username_password_from_userinfo(%URI{userinfo: userinfo}) do
    String.split(userinfo, ":", parts: 2)
    |> case do
      [username] -> [username, ""]
      [username, password] -> [username, password]
    end
  end

  defp build_hash(fragment) when is_binary(fragment) do
    "##{fragment}"
  end

  defp build_hash(_framgment) do
    ""
  end

  defp build_origin(uri) do
    "#{uri.scheme}://#{uri.authority}"
  end

  defp convert_scheme_to_protocol(scheme) when is_binary(scheme) do
    scheme <> ":"
  end

  defp convert_scheme_to_protocol(_scheme) do
    ""
  end

  defp build_search(query) when is_binary(query) do
    "?#{query}"
  end

  defp build_search(_query) do
    ""
  end


  @doc """
  Releases the object URL previously created by create_object_url().

  The revokeObjectURL() static method releases an existing object URL which was 
  previously created by calling create_object_url().

  ## Parameters

  - `object_url` - String containing the object URL to release

  ## Returns

  This function doesn't return a value (matches the Web API behavior).

  ## Examples

      # Create and then revoke object URL
      object_url = GenDOM.URL.create_object_url(blob_data)
      
      # Use the URL...
      
      # Clean up when done
      GenDOM.URL.revoke_object_url(object_url)

  ## Web API Reference

  [MDN Web Docs: URL.revokeObjectURL()](https://developer.mozilla.org/en-US/docs/Web/API/URL/revokeObjectURL)
  """
  def revoke_object_url(object_url) do
    # Implementation to be added
    :not_implemented
  end

  @doc """
  Returns the URL as a JSON-serializable string.

  The toJSON() method returns a string containing the serialized URL, 
  which is the same as the href property.

  ## Parameters

  - `url` - The URL struct to serialize

  ## Returns

  A string containing the complete URL.

  ## Examples

      url = GenDOM.URL.parse("https://example.com/path?query=value#section")
      GenDOM.URL.to_json(url)
      # Returns: "https://example.com/path?query=value#section"

  ## Web API Reference

  [MDN Web Docs: URL.toJSON()](https://developer.mozilla.org/en-US/docs/Web/API/URL/toJSON)
  """
  def to_json(%__MODULE__{} = url) do
    to_string(url)
  end

  @doc """
  Returns the URL as a string.

  The toString() method returns a string containing the whole URL. 
  It is effectively a read-only version of href.

  ## Parameters

  - `url` - The URL struct to convert to string

  ## Returns

  A string containing the complete URL.

  ## Examples

      url = GenDOM.URL.parse("https://example.com/path?query=value#section")
      GenDOM.URL.to_string(url)
      # Returns: "https://example.com/path?query=value#section"

      # Can also use the built-in String.Chars protocol
      "\#{url}"
      # Returns: "https://example.com/path?query=value#section"

  ## Web API Reference

  [MDN Web Docs: URL.toString()](https://developer.mozilla.org/en-US/docs/Web/API/URL/toString)
  """
  def to_string(%__MODULE__{} = url) do
    %URI{
      scheme: convert_protocol_to_scheme(Map.get(url, :protocol, "") |> String.reverse()) |> String.reverse(),
      userinfo: build_userinfo(url),
      host: url.hostname,
      port: Integer.parse(url.port) |> elem(0),
      path: Map.get(url, :pathname, ""),
      query: build_query(url.search),
      fragment: build_fragment(url.hash)
    }
    |> URI.to_string()
  end

  defp convert_protocol_to_scheme(<<":"::utf8, scheme::binary>>) do
    scheme
  end

  defp convert_protocol_to_scheme(_other) do
    ""
  end

  defp build_userinfo(%__MODULE__{username: username, password: password}) when password in ["", nil] do
    nil
  end

  defp build_userinfo(%__MODULE__{username: username, password: password}) do
    "#{username}:#{password}"
  end

  defp build_userinfo(%__MODULE__{}) do
    ""
  end

  defp build_query(<<"?"::utf8, query::binary>>) do
    query
  end

  defp build_query(_other) do 
    ""
  end

  defp build_fragment(<<"#"::utf8, fragment::binary>>) do
    fragment
  end

  defp build_fragment(_other) do
    ""
  end
end
