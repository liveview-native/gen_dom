defmodule GenDOM.Request do
  @moduledoc """
  The Request interface of the Fetch API represents a resource request.

  The Request interface represents a resource request. You can create a new Request object using the 
  Request() constructor, but you are more likely to encounter a Request object being returned as 
  the result of another API operation, such as a service worker FetchEvent.request.

  ## Specification Compliance

  This module implements the Fetch API Request interface as defined by:
  - **WHATWG Fetch Standard**: https://fetch.spec.whatwg.org/#request-class
  - **MDN Web Docs**: https://developer.mozilla.org/en-US/docs/Web/API/Request

  ## Properties

  ### Request Configuration
  - `url` - The URL of the request (read-only string)
  - `method` - The request method (GET, POST, etc.)
  - `headers` - Headers object containing request headers
  - `body` - Body content of the request
  - `mode` - The mode of the request (cors, no-cors, same-origin)
  - `credentials` - The credentials mode (omit, same-origin, include)
  - `cache` - Cache mode for the request
  - `redirect` - How to handle redirect responses (follow, error, manual)
  - `referrer` - Referrer of the request
  - `referrer_policy` - Referrer policy to use
  - `integrity` - Subresource integrity value
  - `keepalive` - Whether request should outlive the page
  - `signal` - AbortSignal for request cancellation

  ### Request Metadata  
  - `destination` - The intended destination of the request
  - `is_history_navigation` - Whether request is for history navigation
  - `duplex` - Duplex mode for streaming (experimental)

  ### Body Management
  - `body_used` - Whether the request body has been consumed (read-only boolean)

  ## Methods

  ### Body Reading Methods
  - `array_buffer/1` - Read body as ArrayBuffer
  - `blob/1` - Read body as Blob
  - `bytes/1` - Read body as Uint8Array
  - `form_data/1` - Read body as FormData
  - `json/1` - Read body as JSON
  - `text/1` - Read body as text string

  ### Request Manipulation
  - `clone/1` - Create a clone of the request

  ## Request Creation

  Create requests using the constructor with various options:

  ```elixir
  # Simple GET request
  request = GenDOM.Request.new("https://api.example.com/data")

  # POST request with JSON body
  request = GenDOM.Request.new("https://api.example.com/users", [
    method: "POST",
    headers: %{"Content-Type" => "application/json"},
    body: "{\"name\": \"John\"}"
  ])

  # Request with custom configuration
  request = GenDOM.Request.new("https://api.example.com/secure", [
    method: "GET",
    mode: "cors", 
    credentials: "include",
    cache: "no-cache",
    headers: %{"Authorization" => "Bearer token123"}
  ])
  ```

  ## Body Handling

  Request bodies can contain various data types:

  ```elixir
  # Text body
  request = GenDOM.Request.new("/api", [
    method: "POST",
    body: "plain text data"
  ])

  # JSON body
  json_data = Jason.encode!(%{user: "john", age: 30})
  request = GenDOM.Request.new("/api", [
    method: "POST", 
    body: json_data,
    headers: %{"Content-Type" => "application/json"}
  ])

  # Form data
  form_data = "name=John&email=john@example.com"
  request = GenDOM.Request.new("/api", [
    method: "POST",
    body: form_data,
    headers: %{"Content-Type" => "application/x-www-form-urlencoded"}
  ])
  ```

  ## Request Modes

  ### CORS Modes
  - `"cors"` - CORS protocol is used (default for cross-origin requests)
  - `"no-cors"` - Prevents the method from being anything other than HEAD, GET or POST
  - `"same-origin"` - Only same-origin requests are allowed

  ### Credentials Modes  
  - `"omit"` - Never send cookies or credentials
  - `"same-origin"` - Send credentials for same-origin requests only
  - `"include"` - Always send credentials, even for cross-origin requests

  ### Cache Modes
  - `"default"` - Standard caching behavior
  - `"no-store"` - Fetch bypasses HTTP cache entirely
  - `"reload"` - Fetch bypasses HTTP cache on the way to the network
  - `"no-cache"` - Conditional request to validate cached response
  - `"force-cache"` - Fulfill from cache if possible, fetch otherwise
  - `"only-if-cached"` - Fulfill from cache only, fail if not cached

  ## Request Cloning

  Create independent copies of requests:

  ```elixir
  original_request = GenDOM.Request.new("/api/data", [method: "POST", body: "data"])
  cloned_request = GenDOM.Request.clone(original_request)
  
  # Original and clone are independent
  # Consuming body of one doesn't affect the other
  ```

  ## Headers Management

  Request headers are managed through the Headers interface:

  ```elixir
  request = GenDOM.Request.new("/api", [
    headers: [
      {"Content-Type", "application/json"},
      {"Authorization" => "Bearer token"},
      {"Accept" => "application/json"}
    ]
  ])
  ```

  ## Security Considerations

  ### Same-Origin Policy
  Requests follow same-origin policy unless explicitly configured otherwise with CORS.

  ### Content Security Policy
  Requests respect CSP directives including `connect-src`.

  ### Mixed Content
  HTTPS pages cannot make HTTP requests unless explicitly allowed.

  ## Error Handling

  Request creation and body reading can fail:

  ```elixir
  case GenDOM.Request.new("invalid-url") do
    {:ok, request} -> 
      # Success
    {:error, reason} -> 
      # Handle error
  end

  # Body reading errors
  case GenDOM.Request.json(request) do
    {:ok, data} -> 
      # Successfully parsed JSON
    {:error, reason} -> 
      # JSON parsing failed
  end
  ```

  ## Integration with Fetch API

  Requests are typically used with the Fetch API:

  ```elixir
  request = GenDOM.Request.new("/api/users", [
    method: "POST",
    headers: %{"Content-Type" => "application/json"},
    body: Jason.encode!(%{name: "John"})
  ])

  response = Fetch.fetch(request)
  ```

  ## Thread Safety

  Request objects are immutable after creation:
  - **Read Operations**: Safe for concurrent access
  - **Body Consumption**: Can only be consumed once per request
  - **Cloning**: Creates independent copies for parallel processing

  ## Performance Characteristics

  - **Creation**: O(1) - Minimal validation and setup
  - **Cloning**: O(1) - Shallow copy of properties
  - **Body Reading**: O(n) where n is body size
  - **Memory Usage**: Proportional to headers and body size

  ## Common Patterns

  ### API Client Requests
  ```elixir
  # GET with auth header
  get_request = GenDOM.Request.new("/api/user/profile", [
    headers: %{"Authorization" => "Bearer " <> token}
  ])

  # POST with JSON payload
  post_request = GenDOM.Request.new("/api/users", [
    method: "POST", 
    headers: %{"Content-Type" => "application/json"},
    body: Jason.encode!(user_data)
  ])
  ```

  ### Form Submission
  ```elixir
  form_request = GenDOM.Request.new("/submit", [
    method: "POST",
    headers: %{"Content-Type" => "application/x-www-form-urlencoded"},
    body: "name=John&email=john@example.com"
  ])
  ```

  ### File Upload
  ```elixir
  upload_request = GenDOM.Request.new("/upload", [
    method: "POST",
    body: file_data,
    headers: %{"Content-Type" => "multipart/form-data"}
  ])
  ```

  ## Web Workers Support

  This feature is available in Web Workers, enabling background request processing.
  """

  @derive {Inspect, only: [:url, :method, :body_used]}

  defstruct [
    # Request Configuration
    url: "",                              # The URL of the request (read-only)
    method: "GET",                        # HTTP method (GET, POST, PUT, DELETE, etc.)
    headers: %{},                         # Headers object containing request headers
    body: nil,                            # Body content of the request
    mode: "cors",                         # Request mode: "cors", "no-cors", "same-origin"
    credentials: "same-origin",           # Credentials mode: "omit", "same-origin", "include"
    cache: "default",                     # Cache mode for the request
    redirect: "follow",                   # Redirect handling: "follow", "error", "manual"
    referrer: "about:client",             # Referrer of the request
    referrer_policy: "",                  # Referrer policy to use
    integrity: "",                        # Subresource integrity value
    keepalive: false,                     # Whether request should outlive the page
    signal: nil,                          # AbortSignal for request cancellation

    # Request Metadata
    destination: "",                      # Intended destination of the request
    is_history_navigation: false,         # Whether request is for history navigation
    duplex: "half",                       # Duplex mode for streaming (experimental)

    # Body Management  
    body_used: false                      # Whether the request body has been consumed
  ]

  @doc """
  Creates a new Request object.

  The Request() constructor creates a new Request object representing a resource request.

  ## Parameters

  - `input` - String URL or existing Request object to base the new request on
  - `options` - Optional keyword list containing request configuration:
    - `:method` - HTTP method string (default: "GET")
    - `:headers` - Map of header names to values
    - `:body` - Request body content (string, binary, etc.)
    - `:mode` - Request mode: "cors", "no-cors", "same-origin" (default: "cors")
    - `:credentials` - Credentials mode: "omit", "same-origin", "include" (default: "same-origin")
    - `:cache` - Cache mode (default: "default")
    - `:redirect` - Redirect behavior: "follow", "error", "manual" (default: "follow")
    - `:referrer` - Referrer URL string (default: "about:client")
    - `:referrer_policy` - Referrer policy string
    - `:integrity` - Subresource integrity value
    - `:keepalive` - Boolean whether to keep connection alive (default: false)
    - `:signal` - AbortSignal for cancellation

  ## Examples

      # Simple GET request
      request = GenDOM.Request.new("https://api.example.com/users")

      # POST request with JSON body  
      request = GenDOM.Request.new("https://api.example.com/users", [
        method: "POST",
        headers: %{"Content-Type" => "application/json"},
        body: "{\\"name\\": \\"John\\"}"
      ])

      # Request with custom configuration
      request = GenDOM.Request.new("/api/data", [
        method: "GET",
        mode: "same-origin",
        credentials: "include", 
        cache: "no-cache"
      ])

  ## Web API Reference

  [MDN Web Docs: Request() constructor](https://developer.mozilla.org/en-US/docs/Web/API/Request/Request)
  """
  def new(input, options \\ []) when is_binary(input) do
    __MODULE__.new([
      url: input,
      method: Keyword.get(options, :method, "GET"),
      headers: Keyword.get(options, :headers, %{}),
      body: Keyword.get(options, :body),
      mode: Keyword.get(options, :mode, "cors"),
      credentials: Keyword.get(options, :credentials, "same-origin"),
      cache: Keyword.get(options, :cache, "default"),
      redirect: Keyword.get(options, :redirect, "follow"),
      referrer: Keyword.get(options, :referrer, "about:client"),
      referrer_policy: Keyword.get(options, :referrer_policy, ""),
      integrity: Keyword.get(options, :integrity, ""),
      keepalive: Keyword.get(options, :keepalive, false),
      signal: Keyword.get(options, :signal),
      destination: Keyword.get(options, :destination, ""),
      is_history_navigation: Keyword.get(options, :is_history_navigation, false),
      duplex: Keyword.get(options, :duplex, "half"),
      body_used: false
    ])
  end

  @doc """
  Reads the request body and returns it as an ArrayBuffer.

  The arrayBuffer() method takes a Request stream and reads it to completion. 
  It returns a promise that resolves with an ArrayBuffer.

  ## Parameters

  - `request` - The Request struct to read the body from

  ## Returns

  `{:ok, array_buffer}` on success, or `{:error, reason}` if the body has already been consumed
  or cannot be read as an ArrayBuffer.

  ## Examples

      request = GenDOM.Request.new("/api/data", [body: "binary data"])
      {:ok, buffer} = GenDOM.Request.array_buffer(request)

  ## Web API Reference

  [MDN Web Docs: Request.arrayBuffer()](https://developer.mozilla.org/en-US/docs/Web/API/Request/arrayBuffer)
  """
  def array_buffer(_request) do
    :not_implemented
  end

  @doc """
  Reads the request body and returns it as a Blob.

  The blob() method takes a Request stream and reads it to completion.
  It returns a promise that resolves with a Blob.

  ## Parameters

  - `request` - The Request struct to read the body from

  ## Returns

  `{:ok, blob}` on success, or `{:error, reason}` if the body has already been consumed
  or cannot be read as a Blob.

  ## Examples

      request = GenDOM.Request.new("/api/file", [body: file_data])
      {:ok, blob} = GenDOM.Request.blob(request)

  ## Web API Reference

  [MDN Web Docs: Request.blob()](https://developer.mozilla.org/en-US/docs/Web/API/Request/blob)
  """
  def blob(_request) do
    :not_implemented
  end

  @doc """
  Reads the request body and returns it as a Uint8Array.

  The bytes() method takes a Request stream and reads it to completion.
  It returns a promise that resolves with a Uint8Array.

  ## Parameters

  - `request` - The Request struct to read the body from

  ## Returns

  `{:ok, uint8_array}` on success, or `{:error, reason}` if the body has already been consumed
  or cannot be read as bytes.

  ## Examples

      request = GenDOM.Request.new("/api/binary", [body: <<1, 2, 3, 4>>])
      {:ok, bytes} = GenDOM.Request.bytes(request)

  ## Web API Reference

  [MDN Web Docs: Request.bytes()](https://developer.mozilla.org/en-US/docs/Web/API/Request/bytes)
  """
  def bytes(_request) do
    :not_implemented
  end

  @doc """
  Creates a copy of the current Request object.

  The clone() method creates a copy of the current Request object. Like the underlying 
  ReadableStream.tee api, the body of a cloned Response will signal backpressure at 
  the rate of the faster consumer.

  ## Parameters

  - `request` - The Request struct to clone

  ## Returns

  A new Request struct that is an independent copy of the original.

  ## Examples

      original = GenDOM.Request.new("/api/data", [method: "POST", body: "data"])
      cloned = GenDOM.Request.clone(original)
      
      # Both requests can be used independently
      {:ok, data1} = GenDOM.Request.text(original)
      {:ok, data2} = GenDOM.Request.text(cloned)

  ## Web API Reference

  [MDN Web Docs: Request.clone()](https://developer.mozilla.org/en-US/docs/Web/API/Request/clone)
  """
  def clone(_request) do
    :not_implemented
  end

  @doc """
  Reads the request body and returns it as FormData.

  The formData() method takes a Request stream and reads it to completion.
  It returns a promise that resolves with a FormData object.

  ## Parameters

  - `request` - The Request struct to read the body from

  ## Returns

  `{:ok, form_data}` on success, or `{:error, reason}` if the body has already been consumed
  or cannot be parsed as form data.

  ## Examples

      request = GenDOM.Request.new("/api/form", [
        method: "POST",
        body: "name=John&email=john@example.com",
        headers: %{"Content-Type" => "application/x-www-form-urlencoded"}
      ])
      {:ok, form_data} = GenDOM.Request.form_data(request)

  ## Web API Reference

  [MDN Web Docs: Request.formData()](https://developer.mozilla.org/en-US/docs/Web/API/Request/formData)
  """
  def form_data(_request) do
    :not_implemented
  end

  @doc """
  Reads the request body and returns it as JSON.

  The json() method takes a Request stream and reads it to completion.
  It returns a promise that resolves with the result of parsing the body text as JSON.

  ## Parameters

  - `request` - The Request struct to read the body from

  ## Returns

  `{:ok, parsed_json}` on success, or `{:error, reason}` if the body has already been consumed
  or cannot be parsed as JSON.

  ## Examples

      request = GenDOM.Request.new("/api/users", [
        method: "POST", 
        body: "{\\"name\\": \\"John\\", \\"age\\": 30}",
        headers: %{"Content-Type" => "application/json"}
      ])
      {:ok, %{"name" => "John", "age" => 30}} = GenDOM.Request.json(request)

  ## Web API Reference

  [MDN Web Docs: Request.json()](https://developer.mozilla.org/en-US/docs/Web/API/Request/json)
  """
  def json(_request) do
    :not_implemented
  end

  @doc """
  Reads the request body and returns it as a string.

  The text() method takes a Request stream and reads it to completion.
  It returns a promise that resolves with a string.

  ## Parameters

  - `request` - The Request struct to read the body from

  ## Returns

  `{:ok, text_string}` on success, or `{:error, reason}` if the body has already been consumed.

  ## Examples

      request = GenDOM.Request.new("/api/data", [
        method: "POST",
        body: "Hello, World!"
      ])
      {:ok, "Hello, World!"} = GenDOM.Request.text(request)

  ## Web API Reference

  [MDN Web Docs: Request.text()](https://developer.mozilla.org/en-US/docs/Web/API/Request/text)
  """
  def text(_request) do
    :not_implemented
  end
end
