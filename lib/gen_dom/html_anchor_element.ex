defmodule GenDOM.HTMLAnchorElement do
  import Kernel, except: [
    to_string: 1
  ]
  @moduledoc """
  The HTMLAnchorElement interface represents hyperlink elements.

  The HTMLAnchorElement interface provides special properties and methods for 
  manipulating the behavior and execution of anchor elements, beyond those 
  available from the regular HTMLElement object interface that it also inherits.

  ## Specification Compliance

  This module implements the HTMLAnchorElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/text-level-semantics.html#htmlanchorelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/textlevel-semantics.html#the-a-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLAnchorElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_anchor_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "a"

  ## Properties

  ### Core Link Properties
  - `href` - The URL that the hyperlink points to
  - `target` - Where to display the linked resource (_blank, _self, _parent, _top)
  - `download` - Suggests filename for download links
  - `rel` - Relationship between current document and linked resource

  ### URL Components (href-derived)
  - `protocol` - URL scheme (e.g., "https:")
  - `host` - Hostname and port (e.g., "example.com:8080")
  - `hostname` - Domain name only (e.g., "example.com")
  - `port` - Port number (e.g., "8080")
  - `pathname` - URL path (e.g., "/path/to/resource")
  - `search` - Query string (e.g., "?param=value")
  - `hash` - Fragment identifier (e.g., "#section1")
  - `origin` - Origin (protocol + hostname + port, read-only)

  ### Link Metadata
  - `hreflang` - Language of the linked resource
  - `type` - MIME type of the linked resource
  - `referrer_policy` - Referrer policy for the link

  ### Experimental/Security Features
  - `attribution_src` - Attribution reporting source (experimental)

  ### Deprecated Properties (for compatibility)
  - `charset` - Character encoding of linked document (deprecated)
  - `coords` - Coordinates for image map areas (deprecated)
  - `name` - Anchor name (deprecated, use id instead)
  - `rev` - Reverse relationship (deprecated)
  - `shape` - Shape of image map area (deprecated)

  ## Methods

  ### URL Manipulation
  - `to_string/1` - Returns the complete URL (same as href)

  ### Inherited Methods
  All methods from HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Basic hyperlink
  link = GenDOM.HTMLAnchorElement.new([
    href: "https://example.com",
    target: "_blank",
    rel: "noopener noreferrer"
  ])

  # Download link
  download_link = GenDOM.HTMLAnchorElement.new([
    href: "/files/document.pdf",
    download: "my-document.pdf",
    type: "application/pdf"
  ])

  # Internal anchor
  internal_link = GenDOM.HTMLAnchorElement.new([
    href: "#section1"
  ])

  # Email link
  email_link = GenDOM.HTMLAnchorElement.new([
    href: "mailto:contact@example.com",
    target: "_blank"
  ])

  # Phone link
  tel_link = GenDOM.HTMLAnchorElement.new([
    href: "tel:+1234567890"
  ])
  ```

  ## Link Types and Relationships

  The `rel` attribute defines the relationship between the current document and the linked resource:

  ```elixir
  # External link with security
  external = GenDOM.HTMLAnchorElement.new([
    href: "https://external-site.com",
    rel: "external noopener noreferrer",
    target: "_blank"
  ])

  # Navigation relationships
  next_page = GenDOM.HTMLAnchorElement.new([
    href: "/page2",
    rel: "next"
  ])

  prev_page = GenDOM.HTMLAnchorElement.new([
    href: "/page1", 
    rel: "prev"
  ])

  # Help link
  help_link = GenDOM.HTMLAnchorElement.new([
    href: "/help",
    rel: "help"
  ])
  ```

  ## URL Parsing and Components

  HTMLAnchorElement automatically parses URLs into components:

  ```elixir
  link = GenDOM.HTMLAnchorElement.new([
    href: "https://user:pass@example.com:8080/path?param=value#section"
  ])

  # Access URL components
  protocol = GenDOM.HTMLAnchorElement.get_protocol(link.pid)  # "https:"
  hostname = GenDOM.HTMLAnchorElement.get_hostname(link.pid)  # "example.com"
  port = GenDOM.HTMLAnchorElement.get_port(link.pid)         # "8080"
  pathname = GenDOM.HTMLAnchorElement.get_pathname(link.pid) # "/path"
  search = GenDOM.HTMLAnchorElement.get_search(link.pid)     # "?param=value"
  hash = GenDOM.HTMLAnchorElement.get_hash(link.pid)         # "#section"
  ```

  ## Download Links

  Configure file downloads with the download attribute:

  ```elixir
  # Suggest filename for download
  download = GenDOM.HTMLAnchorElement.new([
    href: "/api/export/data.csv",
    download: "export-#{Date.utc_today()}.csv",
    type: "text/csv"
  ])

  # Force download (empty download attribute)
  force_download = GenDOM.HTMLAnchorElement.new([
    href: "/image.jpg",
    download: ""  # Forces download instead of navigation
  ])
  ```

  ## Security Considerations

  ### External Links
  ```elixir
  # Secure external link
  secure_external = GenDOM.HTMLAnchorElement.new([
    href: "https://untrusted-site.com",
    target: "_blank",
    rel: "noopener noreferrer"  # Prevents window.opener access
  ])
  ```

  ### Referrer Policy
  ```elixir
  # Control referrer information
  private_link = GenDOM.HTMLAnchorElement.new([
    href: "https://external.com",
    referrer_policy: "no-referrer"
  ])
  ```

  ## Accessibility

  Ensure links are accessible:

  ```elixir
  # Descriptive link text
  accessible_link = GenDOM.HTMLAnchorElement.new([
    href: "/report.pdf",
    download: "annual-report.pdf",
    # Use meaningful text content, not "click here"
  ])

  # External link indication
  external_link = GenDOM.HTMLAnchorElement.new([
    href: "https://external.com",
    target: "_blank",
    rel: "external noopener",
    title: "Opens in new tab"
  ])
  ```

  ## Performance Considerations

  - **Preloading**: Use `<link rel="preload">` for critical resources
  - **Prefetching**: Use `rel="prefetch"` for likely next navigation
  - **DNS Prefetch**: Use `rel="dns-prefetch"` for external domains

  ## Browser Compatibility

  Core HTMLAnchorElement features have universal browser support.
  Modern features like `download` and advanced `rel` values have broad support.
  """

  @derive {Inspect, only: [:pid, :tag_name, :href, :target, :rel]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for anchor-specific behavior
    tag_name: "a",
    
    # Core link properties
    href: "",
    target: "",
    download: "",
    rel: "",

    # URL components (automatically parsed from href)
    protocol: "",
    host: "",
    hostname: "",
    port: "",
    pathname: "",
    search: "",
    hash: "",
    origin: "", # read-only

    # Link metadata
    hreflang: "",
    type: "",
    referrer_policy: "",

    # Experimental features
    attribution_src: "", # experimental

    # Deprecated properties (for compatibility)
    charset: "", # deprecated
    coords: "", # deprecated
    name: "", # deprecated  
    rev: "", # deprecated
    shape: "" # deprecated
  ]

  @doc """
  Returns the complete URL as a string.

  This method implements the HTMLAnchorElement `toString()` specification.
  It returns the same value as the href property.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the complete URL

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com/path?q=test"])
      url = GenDOM.HTMLAnchorElement.to_string(anchor.pid)
      # Returns: "https://example.com/path?q=test"
  """
  def to_string(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.href
  end

  @doc """
  Sets the URL that the hyperlink points to.

  Updates the href attribute and automatically parses URL components.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement
  - `url` - The URL string

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([])
      GenDOM.HTMLAnchorElement.set_href(anchor.pid, "https://example.com:8080/path?q=test#section")
      
      # URL components are automatically parsed:
      # protocol: "https:"
      # hostname: "example.com"  
      # port: "8080"
      # pathname: "/path"
      # search: "?q=test"
      # hash: "#section"
  """
  def set_href(anchor_pid, url) when is_binary(url) do
    # Parse URL components
    uri = URI.parse(url)
    
    components = %{
      href: url,
      protocol: if(uri.scheme, do: "#{uri.scheme}:", else: ""),
      hostname: uri.host || "",
      port: if(uri.port, do: to_string(uri.port), else: ""),
      pathname: uri.path || "",
      search: if(uri.query, do: "?#{uri.query}", else: ""),
      hash: if(uri.fragment, do: "##{uri.fragment}", else: ""),
      host: case {uri.host, uri.port} do
        {nil, _} -> ""
        {host, nil} -> host
        {host, port} -> "#{host}:#{port}"
      end,
      origin: case {uri.scheme, uri.host, uri.port} do
        {nil, _, _} -> ""
        {scheme, nil, _} -> ""
        {scheme, host, nil} -> "#{scheme}://#{host}"
        {scheme, host, port} -> "#{scheme}://#{host}:#{port}"
      end
    }
    
    GenDOM.Node.merge(anchor_pid, components)
  end

  @doc """
  Gets the protocol component of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the protocol (e.g., "https:")

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com"])
      protocol = GenDOM.HTMLAnchorElement.get_protocol(anchor.pid)
      # Returns: "https:"
  """
  def get_protocol(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.protocol
  end

  @doc """
  Gets the hostname component of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the hostname

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com:8080/path"])
      hostname = GenDOM.HTMLAnchorElement.get_hostname(anchor.pid)
      # Returns: "example.com"
  """
  def get_hostname(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.hostname
  end

  @doc """
  Gets the port component of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the port number

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com:8080/path"])
      port = GenDOM.HTMLAnchorElement.get_port(anchor.pid)
      # Returns: "8080"
  """
  def get_port(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.port
  end

  @doc """
  Gets the pathname component of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the path

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com/path/to/page"])
      pathname = GenDOM.HTMLAnchorElement.get_pathname(anchor.pid)
      # Returns: "/path/to/page"
  """
  def get_pathname(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.pathname
  end

  @doc """
  Gets the search (query string) component of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the query string including the "?" prefix

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com/search?q=test&lang=en"])
      search = GenDOM.HTMLAnchorElement.get_search(anchor.pid)
      # Returns: "?q=test&lang=en"
  """
  def get_search(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.search
  end

  @doc """
  Gets the hash (fragment) component of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the fragment including the "#" prefix

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com/page#section1"])
      hash = GenDOM.HTMLAnchorElement.get_hash(anchor.pid)
      # Returns: "#section1"
  """
  def get_hash(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.hash
  end

  @doc """
  Gets the origin of the URL.

  Returns the protocol, hostname, and port of the URL.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  String containing the origin

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com:8080/path"])
      origin = GenDOM.HTMLAnchorElement.get_origin(anchor.pid)
      # Returns: "https://example.com:8080"
  """
  def get_origin(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.origin
  end

  @doc """
  Sets the target attribute for the link.

  Specifies where to display the linked resource.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement
  - `target` - Target value ("_blank", "_self", "_parent", "_top", or frame name)

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://example.com"])
      GenDOM.HTMLAnchorElement.set_target(anchor.pid, "_blank")
  """
  def set_target(anchor_pid, target) when is_binary(target) do
    GenDOM.Node.put(anchor_pid, :target, target)
  end

  @doc """
  Sets the relationship between the current document and the linked resource.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement
  - `relationship` - Relationship value (e.g., "noopener", "noreferrer", "external")

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://external.com"])
      GenDOM.HTMLAnchorElement.set_rel(anchor.pid, "external noopener noreferrer")
  """
  def set_rel(anchor_pid, relationship) when is_binary(relationship) do
    GenDOM.Node.put(anchor_pid, :rel, relationship)
  end

  @doc """
  Sets the download attribute for the link.

  Suggests that the linked resource should be downloaded with the given filename.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement
  - `filename` - Suggested filename for download

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "/report.pdf"])
      GenDOM.HTMLAnchorElement.set_download(anchor.pid, "annual-report.pdf")
  """
  def set_download(anchor_pid, filename) when is_binary(filename) do
    GenDOM.Node.put(anchor_pid, :download, filename)
  end

  @doc """
  Checks if this is an external link.

  Returns true if the link points to a different origin than the current document.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement
  - `current_origin` - The origin of the current document

  ## Returns

  Boolean indicating if the link is external

  ## Examples

      anchor = GenDOM.HTMLAnchorElement.new([href: "https://external.com/page"])
      is_external = GenDOM.HTMLAnchorElement.is_external?(anchor.pid, "https://mysite.com")
      # Returns: true
  """
  def is_external?(anchor_pid, current_origin) when is_binary(current_origin) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.origin != "" and anchor.origin != current_origin
  end

  @doc """
  Checks if this is a download link.

  Returns true if the download attribute is set.

  ## Parameters

  - `anchor_pid` - The PID of the HTMLAnchorElement

  ## Returns

  Boolean indicating if this is a download link

  ## Examples

      download_link = GenDOM.HTMLAnchorElement.new([href: "/file.pdf", download: "document.pdf"])
      is_download = GenDOM.HTMLAnchorElement.is_download?(download_link.pid)
      # Returns: true
  """
  def is_download?(anchor_pid) do
    anchor = GenDOM.Node.get(anchor_pid)
    anchor.download != ""
  end
end
