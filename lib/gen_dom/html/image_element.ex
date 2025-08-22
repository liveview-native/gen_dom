defmodule GenDOM.HTMLImageElement do
  @moduledoc """
  The HTMLImageElement interface represents an HTML `<img>` element.

  The HTMLImageElement interface provides special properties and methods for manipulating
  `<img>` elements. It inherits all properties and methods from HTMLElement and Element,
  and adds image-specific functionality for loading, sizing, and displaying images.

  ## Specification Compliance

  This module implements the HTMLImageElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/embedded-content.html#htmlimageelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/semantics-embedded-content.html#the-img-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLImageElement (extends HTMLElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_image_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "img"

  ## Properties

  ### Image Source and Content
  - `src` - URL of the image to display
  - `alt` - Alternative text for accessibility and fallback
  - `srcset` - Set of source candidates for responsive images
  - `sizes` - Conditional image sizes for different viewport widths
  - `current_src` - Currently selected image URL (read-only)

  ### Image Dimensions
  - `width` - Rendered image width in CSS pixels
  - `height` - Rendered image height in CSS pixels
  - `natural_width` - Intrinsic image width (read-only)
  - `natural_height` - Intrinsic image height (read-only)

  ### Loading and State
  - `complete` - Whether image loading has completed (read-only)
  - `loading` - Image loading strategy ("eager", "lazy")
  - `decode_priority` - Decoding priority hint ("high", "low", "auto")
  - `fetch_priority` - Fetch priority hint ("high", "low", "auto")

  ### CORS and Security
  - `cross_origin` - CORS settings ("anonymous", "use-credentials", or nil)
  - `referrer_policy` - Referrer policy for image requests
  - `attribution_src` - Attribution reporting source (experimental)

  ### Deprecated Properties
  - `align` - Image alignment (deprecated, use CSS)
  - `border` - Image border (deprecated, use CSS)
  - `hspace` - Horizontal spacing (deprecated, use CSS)
  - `vspace` - Vertical spacing (deprecated, use CSS)
  - `name` - Element name (deprecated)
  - `long_desc` - Long description URL (deprecated)

  ## Methods

  ### Image Decoding
  - `decode/1` - Asynchronously decode image data

  ### Inherited Methods
  All methods from HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Create an image element
  image = GenDOM.HTMLImageElement.new([
    src: "https://example.com/photo.jpg",
    alt: "A beautiful landscape",
    width: 800,
    height: 600,
    loading: "lazy"
  ])

  # Responsive image with srcset
  responsive_image = GenDOM.HTMLImageElement.new([
    src: "default.jpg",
    srcset: "small.jpg 480w, medium.jpg 800w, large.jpg 1200w",
    sizes: "(max-width: 600px) 480px, (max-width: 900px) 800px, 1200px",
    alt: "Responsive image"
  ])

  # Check if image is loaded
  is_complete = GenDOM.HTMLImageElement.get(image.pid).complete

  # Decode image asynchronously
  GenDOM.HTMLImageElement.decode(image.pid)
  ```

  ## Image Loading States

  Images progress through several loading states:

  1. **Initial** - Image element created, no src set
  2. **Loading** - Image URL set, loading in progress
  3. **Complete** - Image loaded successfully or failed
  4. **Error** - Image failed to load

  ```elixir
  # Monitor loading state
  image_state = GenDOM.HTMLImageElement.get(image.pid)
  case image_state.complete do
    true -> # Image loaded (success or error)
    false -> # Still loading
  end
  ```

  ## Responsive Images

  HTMLImageElement supports responsive images through srcset and sizes:

  ```elixir
  # Multiple resolution candidates
  image = GenDOM.HTMLImageElement.new([
    src: "photo.jpg",
    srcset: "photo-1x.jpg 1x, photo-2x.jpg 2x, photo-3x.jpg 3x",
    alt: "High DPI image"
  ])

  # Width-based selection
  image = GenDOM.HTMLImageElement.new([
    src: "default.jpg",
    srcset: "small.jpg 300w, medium.jpg 600w, large.jpg 1200w",
    sizes: "(max-width: 320px) 280px, (max-width: 640px) 560px, 1120px"
  ])
  ```

  ## Performance Optimization

  ### Lazy Loading
  ```elixir
  # Defer loading until image enters viewport
  image = GenDOM.HTMLImageElement.new([
    src: "large-image.jpg",
    loading: "lazy",
    alt: "Lazy loaded image"
  ])
  ```

  ### Fetch Priority
  ```elixir
  # Prioritize critical images
  hero_image = GenDOM.HTMLImageElement.new([
    src: "hero.jpg",
    fetch_priority: "high",
    alt: "Hero image"
  ])
  ```

  ### Decoding Hints
  ```elixir
  # Control image decoding strategy
  image = GenDOM.HTMLImageElement.new([
    src: "photo.jpg",
    decoding: "async", # or "sync", "auto"
    alt: "Async decoded image"
  ])
  ```

  ## CORS and Security

  ### Cross-Origin Images
  ```elixir
  # Enable CORS for cross-origin images
  image = GenDOM.HTMLImageElement.new([
    src: "https://external.com/image.jpg",
    cross_origin: "anonymous",
    alt: "Cross-origin image"
  ])
  ```

  ### Referrer Policy
  ```elixir
  # Control referrer information
  image = GenDOM.HTMLImageElement.new([
    src: "sensitive-image.jpg",
    referrer_policy: "no-referrer",
    alt: "Privacy-protected image"
  ])
  ```

  ## Events

  HTMLImageElement supports image-specific events:
  - **load** - Image loaded successfully
  - **error** - Image failed to load
  - **abort** - Image loading was aborted

  ## Accessibility

  Always provide meaningful alt text:

  ```elixir
  # Descriptive alt text
  image = GenDOM.HTMLImageElement.new([
    src: "chart.jpg",
    alt: "Sales increased 15% from Q1 to Q2, shown in a bar chart"
  ])

  # Decorative images
  decorative = GenDOM.HTMLImageElement.new([
    src: "border.png",
    alt: "", # Empty alt for decorative images
    role: "presentation"
  ])
  ```

  ## Performance Considerations

  - **Image Size**: Use appropriate dimensions to avoid layout shifts
  - **Format Selection**: Browser selects optimal format from srcset
  - **Lazy Loading**: Reduces initial page load time
  - **Preloading**: Use `<link rel="preload">` for critical images
  - **Compression**: Balance quality vs. file size

  ## Browser Compatibility

  Core HTMLImageElement features are universally supported.
  Modern features like lazy loading and fetch priority have broad support.

  ## Security Considerations

  - **Cross-Origin**: Use CORS headers for cross-origin images
  - **Content Security Policy**: Configure image-src directive
  - **Hot-linking**: Implement referrer checks to prevent unauthorized use
  - **File Size**: Validate image dimensions and file sizes
  """

  @derive {Inspect, only: [:pid, :tag_name, :src, :alt, :width, :height]}

  use GenDOM.HTMLElement, [
    # Override HTMLElement defaults for img-specific behavior
    tag_name: "img",

    # Image source and content
    src: "",
    alt: "",
    srcset: "",
    sizes: "",
    current_src: "", # read-only, set by browser

    # Image dimensions
    width: 0,
    height: 0,
    natural_width: 0, # read-only, set when image loads
    natural_height: 0, # read-only, set when image loads

    # Loading and state
    complete: false, # read-only, true when loading finished
    loading: "eager", # "eager" | "lazy"
    decoding: "auto", # "auto" | "sync" | "async"
    fetch_priority: "auto", # "auto" | "high" | "low"

    # CORS and security
    cross_origin: nil, # nil | "anonymous" | "use-credentials"
    referrer_policy: "", # various values
    attribution_src: "", # experimental

    # Deprecated properties (for backward compatibility)
    align: "", # deprecated
    border: "", # deprecated
    hspace: 0, # deprecated
    vspace: 0, # deprecated
    name: "", # deprecated
    long_desc: "" # deprecated
  ]

  @doc """
  Asynchronously decodes the image data.

  This method implements the HTMLImageElement `decode()` specification. It returns
  a promise that resolves when the image is ready to be rendered without causing
  blocking decode operations.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement to decode

  ## Returns

  Returns `:ok` when decoding is complete, or `{:error, reason}` if decoding fails.

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "large-image.jpg"])
      result = GenDOM.HTMLImageElement.decode(image.pid)
      case result do
        :ok -> # Image ready for rendering
        {:error, reason} -> # Decoding failed
      end

  ## Specification

  From the HTML Standard: "The decode() method, when invoked, must run the decode image algorithm."

  ## Use Cases

  - **Smooth Animations**: Decode before starting image transitions
  - **Performance**: Avoid blocking main thread during render
  - **User Experience**: Prevent jank when large images appear

  ## Browser Behavior

  - Modern browsers perform async decoding by default
  - Method provides explicit control over decode timing
  - Useful for critical rendering path optimization
  """
  def decode(_image_pid) do
    # Implementation stub - in real implementation would:
    # 1. Check if image src is set and valid
    # 2. Initiate async decode operation
    # 3. Return appropriate result
    :ok
  end

  @doc """
  Gets the current source URL being used for the image.

  This method returns the URL that the browser has selected from the srcset,
  or the src attribute if no srcset is provided.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement

  ## Returns

  String containing the current source URL

  ## Examples

      image = GenDOM.HTMLImageElement.new([
        src: "default.jpg",
        srcset: "small.jpg 480w, large.jpg 1200w"
      ])

      current_url = GenDOM.HTMLImageElement.get_current_src(image.pid)
      # Returns the URL selected by browser based on viewport
  """
  def get_current_src(image_pid) do
    image = GenDOM.Node.get(image_pid)
    image.current_src
  end

  @doc """
  Checks if the image has completed loading.

  Returns true if the image has finished loading (successfully or with error),
  false if still loading or no src is set.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement

  ## Returns

  Boolean indicating completion status

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "photo.jpg"])

      if GenDOM.HTMLImageElement.is_complete?(image.pid) do
        # Image finished loading
      else
        # Still loading or no source
      end
  """
  def is_complete?(image_pid) do
    image = GenDOM.Node.get(image_pid)
    image.complete
  end

  @doc """
  Gets the natural dimensions of the image.

  Returns the intrinsic width and height of the image in pixels,
  as determined by the image file itself.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement

  ## Returns

  Tuple of `{width, height}` in pixels

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "photo.jpg"])
      {natural_width, natural_height} = GenDOM.HTMLImageElement.get_natural_size(image.pid)
      # Returns actual image dimensions, e.g., {1920, 1080}
  """
  def get_natural_size(image_pid) do
    image = GenDOM.Node.get(image_pid)
    {image.natural_width, image.natural_height}
  end

  @doc """
  Sets the image source and triggers loading.

  This method sets the src attribute and initiates image loading.
  Triggers load/error events when loading completes.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement
  - `url` - The URL of the image to load

  ## Examples

      image = GenDOM.HTMLImageElement.new([])
      GenDOM.HTMLImageElement.set_src(image.pid, "https://example.com/photo.jpg")
  """
  def set_src(image_pid, url) when is_binary(url) do
    GenDOM.Node.set(image_pid, :src, url)
    # In real implementation, would trigger image loading
  end

  @doc """
  Sets the alternative text for the image.

  Updates the alt attribute which provides alternative text for screen readers
  and when the image cannot be displayed.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement
  - `alt_text` - Alternative text description

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "chart.jpg"])
      GenDOM.HTMLImageElement.set_alt(image.pid, "Sales chart showing 15% growth")
  """
  def set_alt(image_pid, alt_text) when is_binary(alt_text) do
    GenDOM.Node.set(image_pid, :alt, alt_text)
  end

  @doc """
  Sets the display dimensions of the image.

  Updates the width and height attributes which control how the image
  is displayed (not the intrinsic image size).

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement  
  - `width` - Display width in pixels
  - `height` - Display height in pixels

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "photo.jpg"])
      GenDOM.HTMLImageElement.set_size(image.pid, 400, 300)
  """
  def set_size(image_pid, width, height) when is_integer(width) and is_integer(height) do
    GenDOM.Node.merge(image_pid, %{width: width, height: height})
  end

  @doc """
  Configures responsive image sources.

  Sets the srcset and sizes attributes for responsive image delivery.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement
  - `srcset` - Source set string with image candidates
  - `sizes` - Sizes string with conditional image sizes

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "default.jpg"])
      GenDOM.HTMLImageElement.set_responsive_sources(
        image.pid,
        "small.jpg 480w, medium.jpg 800w, large.jpg 1200w",
        "(max-width: 600px) 480px, (max-width: 900px) 800px, 1200px"
      )
  """
  def set_responsive_sources(image_pid, srcset, sizes) when is_binary(srcset) and is_binary(sizes) do
    GenDOM.Node.merge(image_pid, %{srcset: srcset, sizes: sizes})
  end

  @doc """
  Enables or disables lazy loading for the image.

  Sets the loading attribute to control when the image is loaded.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement
  - `loading_strategy` - "eager" (load immediately) or "lazy" (load when needed)

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "large-image.jpg"])
      GenDOM.HTMLImageElement.set_loading_strategy(image.pid, "lazy")
  """
  def set_loading_strategy(image_pid, loading_strategy) when loading_strategy in ["eager", "lazy"] do
    GenDOM.Node.set(image_pid, :loading, loading_strategy)
  end

  @doc """
  Configures CORS settings for cross-origin images.

  Sets the crossorigin attribute to control CORS behavior for images
  loaded from different origins.

  ## Parameters

  - `image_pid` - The PID of the HTMLImageElement
  - `cors_setting` - nil (no CORS), "anonymous", or "use-credentials"

  ## Examples

      image = GenDOM.HTMLImageElement.new([src: "https://external.com/image.jpg"])
      GenDOM.HTMLImageElement.set_cross_origin(image.pid, "anonymous")
  """
  def set_cross_origin(image_pid, cors_setting) when cors_setting in [nil, "anonymous", "use-credentials"] do
    GenDOM.Node.set(image_pid, :cross_origin, cors_setting)
  end
end
