defmodule GenDOM.HTMLVideoElement do
  @moduledoc """
  The HTMLVideoElement interface represents an HTML `<video>` element.

  The HTMLVideoElement interface provides special properties and methods for manipulating
  `<video>` elements. It inherits all properties and methods from HTMLMediaElement and adds
  video-specific functionality for dimensions, poster images, picture-in-picture mode, 
  and video quality management.

  ## Specification Compliance

  This module implements the HTMLVideoElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/media.html#htmlvideoelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/semantics-embedded-content.html#the-video-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLMediaElement (extends HTMLElement)
              └── GenDOM.HTMLVideoElement (extends HTMLMediaElement)
  ```

  **Inherits from:** `GenDOM.HTMLMediaElement`
  **File:** `lib/gen_dom/html_video_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "video"

  ## Properties

  ### Video Dimensions
  - `width` - Display width in CSS pixels
  - `height` - Display height in CSS pixels
  - `video_width` - Intrinsic video width in pixels (read-only)
  - `video_height` - Intrinsic video height in pixels (read-only)

  ### Poster and Presentation
  - `poster` - URL of image to show before video loads or plays

  ### Picture-in-Picture
  - `disable_picture_in_picture` - Whether picture-in-picture mode is disabled
  - `autopictureinpicture` - Whether to automatically enter PiP when switching tabs

  ### Inherited Properties
  All properties from HTMLMediaElement, HTMLElement, Element, and Node are available:
  - Media control (play, pause, currentTime, duration, volume)
  - Loading states (readyState, networkState)
  - Track management (audioTracks, videoTracks, textTracks)
  - Cross-origin settings

  ## Methods

  ### Picture-in-Picture
  - `request_picture_in_picture/1` - Request entering picture-in-picture mode

  ### Video Quality and Performance
  - `get_video_playback_quality/1` - Get video quality metrics
  - `request_video_frame_callback/2` - Register callback for video frames
  - `cancel_video_frame_callback/2` - Cancel video frame callback

  ### Inherited Methods
  All methods from HTMLMediaElement, HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Create a video element
  video = GenDOM.HTMLVideoElement.new([
    src: "https://example.com/video.mp4",
    width: 800,
    height: 450,
    poster: "https://example.com/poster.jpg",
    controls: true,
    autoplay: false
  ])

  # Set video dimensions
  GenDOM.HTMLVideoElement.set_size(video.pid, 1024, 576)

  # Control playback (inherited from HTMLMediaElement)
  GenDOM.HTMLVideoElement.play(video.pid)
  GenDOM.HTMLVideoElement.pause(video.pid)

  # Picture-in-picture mode
  GenDOM.HTMLVideoElement.request_picture_in_picture(video.pid)

  # Get video quality metrics
  quality = GenDOM.HTMLVideoElement.get_video_playback_quality(video.pid)
  ```

  ## Video Dimensions and Aspect Ratio

  Videos have both display dimensions and intrinsic dimensions:

  ```elixir
  video = GenDOM.HTMLVideoElement.new([
    src: "1920x1080_video.mp4",
    width: 800,
    height: 450
  ])

  # Display dimensions (how video appears in layout)
  display_size = {video.width, video.height} # {800, 450}

  # Intrinsic dimensions (actual video resolution)
  {intrinsic_width, intrinsic_height} = GenDOM.HTMLVideoElement.get_video_size(video.pid)
  # Returns {1920, 1080} once video metadata loads
  ```

  ## Poster Images

  Poster images provide visual content before video loads:

  ```elixir
  # Set poster image
  video = GenDOM.HTMLVideoElement.new([
    src: "video.mp4",
    poster: "poster.jpg",
    width: 640,
    height: 360
  ])

  # Update poster dynamically
  GenDOM.HTMLVideoElement.set_poster(video.pid, "new-poster.jpg")
  ```

  ## Picture-in-Picture Mode

  Modern browsers support picture-in-picture for floating video windows:

  ```elixir
  # Request picture-in-picture
  result = GenDOM.HTMLVideoElement.request_picture_in_picture(video.pid)
  case result do
    {:ok, pip_window} -> # Entered PiP successfully
    {:error, reason} -> # PiP request failed
  end

  # Disable picture-in-picture
  video = GenDOM.HTMLVideoElement.new([
    src: "video.mp4",
    disable_picture_in_picture: true
  ])

  # Auto picture-in-picture when tab becomes inactive
  video = GenDOM.HTMLVideoElement.new([
    src: "video.mp4",
    autopictureinpicture: true
  ])
  ```

  ## Video Quality and Performance

  Monitor video performance and quality:

  ```elixir
  # Get playback quality metrics
  quality = GenDOM.HTMLVideoElement.get_video_playback_quality(video.pid)
  
  # Example quality metrics:
  # %{
  #   creation_time: 1234567890,
  #   total_video_frames: 1500,
  #   dropped_video_frames: 12,
  #   corrupted_video_frames: 0,
  #   total_frame_delay: 0.5
  # }

  dropped_percentage = quality.dropped_video_frames / quality.total_video_frames * 100
  ```

  ## Video Frame Callbacks

  Register callbacks for each video frame:

  ```elixir
  # Register frame callback
  callback_id = GenDOM.HTMLVideoElement.request_video_frame_callback(
    video.pid,
    fn frame_data ->
      # Process each video frame
      # frame_data contains timing and metadata
    end
  )

  # Cancel callback when done
  GenDOM.HTMLVideoElement.cancel_video_frame_callback(video.pid, callback_id)
  ```

  ## Responsive Video

  Create responsive videos that adapt to container size:

  ```elixir
  # Responsive video with aspect ratio
  video = GenDOM.HTMLVideoElement.new([
    src: "video.mp4",
    width: "100%", # Use CSS for responsive sizing
    height: "auto",
    style: %{"aspect-ratio" => "16/9"}
  ])
  ```

  ## Video Formats and Compatibility

  ```elixir
  # Check format support before setting source
  formats = [
    "video/mp4; codecs=\\"avc1.42E01E, mp4a.40.2\\"",
    "video/webm; codecs=\\"vp9, opus\\"",
    "video/ogg; codecs=\\"theora, vorbis\\""
  ]

  supported_format = Enum.find(formats, fn format ->
    GenDOM.HTMLVideoElement.can_play_type(video.pid, format) == "probably"
  end)

  if supported_format do
    GenDOM.HTMLVideoElement.set_src(video.pid, "video." <> get_extension(supported_format))
  end
  ```

  ## Performance Optimization

  ### Lazy Loading
  ```elixir
  # Defer video loading until needed
  video = GenDOM.HTMLVideoElement.new([
    src: "large-video.mp4",
    preload: "none", # Don't preload any data
    poster: "poster.jpg"
  ])
  ```

  ### Preload Strategies
  ```elixir
  # Preload metadata only (dimensions, duration)
  video = GenDOM.HTMLVideoElement.new([
    src: "video.mp4",
    preload: "metadata"
  ])

  # Preload entire video
  critical_video = GenDOM.HTMLVideoElement.new([
    src: "intro.mp4", 
    preload: "auto"
  ])
  ```

  ## Events

  HTMLVideoElement supports video-specific events in addition to HTMLMediaElement events:

  ### Picture-in-Picture Events
  - **enterpictureinpicture** - Entered picture-in-picture mode
  - **leavepictureinpicture** - Exited picture-in-picture mode

  ### Dimension Events
  - **resize** - Video dimensions changed
  - **loadedmetadata** - Video metadata loaded (includes dimensions)

  ## Accessibility

  Make videos accessible to all users:

  ```elixir
  # Provide captions and descriptions
  video = GenDOM.HTMLVideoElement.new([
    src: "presentation.mp4",
    poster: "presentation-poster.jpg"
  ])

  # Add caption track
  GenDOM.HTMLVideoElement.add_text_track(
    video.pid,
    "captions",
    "English Captions", 
    "en"
  )

  # Add description track for visually impaired users
  GenDOM.HTMLVideoElement.add_text_track(
    video.pid,
    "descriptions",
    "Audio Descriptions",
    "en"
  )
  ```

  ## Security Considerations

  - **Cross-Origin**: Configure CORS for external video sources
  - **Content Security Policy**: Set media-src directive appropriately
  - **Autoplay Policies**: Modern browsers restrict autoplay
  - **Bandwidth**: Consider data usage for mobile users

  ## Browser Compatibility

  Core HTMLVideoElement features are universally supported.
  Advanced features have varying support:
  - Picture-in-Picture: Chrome 70+, Safari 13.1+
  - Video Frame Callbacks: Chrome 83+
  - AutoPictureInPicture: Chrome 85+

  ## Performance Considerations

  - **Video Size**: Balance quality vs. file size and bandwidth
  - **Codec Selection**: Use efficient codecs (H.264, VP9, AV1)
  - **Adaptive Streaming**: Consider HLS or DASH for long videos
  - **Frame Rate**: Higher frame rates increase file size significantly
  - **Resolution**: Provide multiple resolutions for different devices
  """

  @derive {Inspect, only: [:pid, :tag_name, :src, :width, :height, :poster]}

  use GenDOM.HTMLMediaElement, [
    # Override HTMLMediaElement defaults for video-specific behavior
    tag_name: "video",

    # Video dimensions
    width: 0,
    height: 0,
    video_width: 0, # read-only, intrinsic width
    video_height: 0, # read-only, intrinsic height

    # Poster and presentation
    poster: "",

    # Picture-in-Picture
    disable_picture_in_picture: false,
    autopictureinpicture: false
  ]

  @doc """
  Requests entering picture-in-picture mode for the video.

  This method implements the Picture-in-Picture API `requestPictureInPicture()` specification.
  It requests that the video be displayed in a floating window that stays on top of other windows.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement

  ## Returns

  Returns `{:ok, pip_window}` if successful, or `{:error, reason}` if failed.

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4", controls: true])
      result = GenDOM.HTMLVideoElement.request_picture_in_picture(video.pid)
      case result do
        {:ok, pip_window} -> 
          # Video is now in picture-in-picture mode
          # pip_window contains PictureInPictureWindow object
        {:error, :not_supported} -> 
          # Picture-in-picture not supported
        {:error, :no_video} ->
          # No video is loaded or playing
        {:error, :user_gesture_required} ->
          # User interaction required
      end

  ## Specification

  From the Picture-in-Picture API specification: "The requestPictureInPicture() method
  requests that the video enters picture-in-picture mode."

  ## Requirements

  - Video must have video content (not audio-only)
  - Usually requires user gesture (click, touch, etc.)
  - Browser must support Picture-in-Picture API
  - Video element must not have disablePictureInPicture set

  ## Events

  - Fires 'enterpictureinpicture' event on success
  - PictureInPictureWindow fires 'resize' events

  ## Browser Support

  - Chrome 70+
  - Safari 13.1+
  - Not supported in Firefox (as of 2024)
  """
  def request_picture_in_picture(video_pid) do
    video = GenDOM.Node.get(video_pid)
    
    cond do
      video.disable_picture_in_picture ->
        {:error, :disabled}
      
      video.video_width == 0 or video.video_height == 0 ->
        {:error, :no_video}
      
      true ->
        # Implementation would:
        # 1. Check if PiP is supported
        # 2. Verify user gesture requirement
        # 3. Create PictureInPictureWindow
        # 4. Fire enterpictureinpicture event
        pip_window = %{
          width: video.video_width,
          height: video.video_height
        }
        {:ok, pip_window}
    end
  end

  @doc """
  Gets video quality and performance metrics.

  This method implements the VideoPlaybackQuality interface, returning detailed
  metrics about video playback performance including dropped frames and timing.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement

  ## Returns

  Map containing video quality metrics:
  - `creation_time` - When the metrics were created
  - `total_video_frames` - Total frames presented
  - `dropped_video_frames` - Frames dropped during playback
  - `corrupted_video_frames` - Frames corrupted during decoding

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      quality = GenDOM.HTMLVideoElement.get_video_playback_quality(video.pid)
      
      %{
        creation_time: creation_time,
        total_video_frames: total_frames,
        dropped_video_frames: dropped_frames,
        corrupted_video_frames: corrupted_frames
      } = quality

      # Calculate drop percentage
      drop_rate = dropped_frames / total_frames * 100

  ## Specification

  From the HTML Standard: "The getVideoPlaybackQuality() method must return a new
  VideoPlaybackQuality object."

  ## Use Cases

  - Monitor playback performance
  - Detect quality issues
  - Adaptive bitrate decisions
  - Performance analytics
  """
  def get_video_playback_quality(video_pid) do
    # Implementation would return actual metrics
    # For now, return mock data
    %{
      creation_time: :os.system_time(:millisecond),
      total_video_frames: 1500,
      dropped_video_frames: 12,
      corrupted_video_frames: 0
    }
  end

  @doc """
  Registers a callback to be called for each video frame.

  This method implements the requestVideoFrameCallback API, allowing frame-by-frame
  processing of video content for advanced use cases like video analysis or effects.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement
  - `callback` - Function to call for each frame

  ## Returns

  Callback ID that can be used to cancel the callback

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      
      callback_id = GenDOM.HTMLVideoElement.request_video_frame_callback(
        video.pid,
        fn frame_data ->
          # Process frame data
          %{
            now: now,
            metadata: %{
              presentation_time: presentation_time,
              expected_display_time: expected_display_time,
              width: width,
              height: height,
              media_time: media_time
            }
          } = frame_data
          
          # Custom frame processing here
        end
      )

  ## Specification

  From the requestVideoFrameCallback specification: "The requestVideoFrameCallback()
  method registers a callback to be fired for the next video frame."

  ## Use Cases

  - Video analysis and computer vision
  - Custom video effects
  - Performance monitoring
  - Frame-accurate video editing

  ## Browser Support

  - Chrome 83+
  - Safari 15.4+
  - Limited support in other browsers
  """
  def request_video_frame_callback(video_pid, callback) when is_function(callback) do
    # Implementation would:
    # 1. Register callback for next frame
    # 2. Return unique callback ID
    # 3. Call callback with frame metadata
    callback_id = :erlang.make_ref()
    
    # Store callback for frame processing
    # In real implementation, this would integrate with video frame events
    
    callback_id
  end

  @doc """
  Cancels a previously registered video frame callback.

  This method cancels a callback registered with request_video_frame_callback().

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement
  - `callback_id` - ID returned from request_video_frame_callback

  ## Examples

      callback_id = GenDOM.HTMLVideoElement.request_video_frame_callback(
        video.pid, 
        fn _frame -> :ok end
      )
      
      # Cancel the callback
      GenDOM.HTMLVideoElement.cancel_video_frame_callback(video.pid, callback_id)

  ## Specification

  From the requestVideoFrameCallback specification: "The cancelVideoFrameCallback()
  method cancels an existing video frame request callback."
  """
  def cancel_video_frame_callback(_video_pid, _callback_id) do
    # Implementation would remove callback from registry
    :ok
  end

  @doc """
  Sets the display dimensions of the video.

  Updates the width and height attributes which control how the video
  is displayed (not the intrinsic video dimensions).

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement
  - `width` - Display width in pixels
  - `height` - Display height in pixels

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      GenDOM.HTMLVideoElement.set_size(video.pid, 1024, 576)
  """
  def set_size(video_pid, width, height) when is_integer(width) and is_integer(height) do
    GenDOM.Node.merge(video_pid, %{width: width, height: height})
  end

  @doc """
  Sets the poster image URL.

  Updates the poster attribute which specifies an image to show before
  the video loads or starts playing.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement
  - `poster_url` - URL of the poster image

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      GenDOM.HTMLVideoElement.set_poster(video.pid, "https://example.com/poster.jpg")
  """
  def set_poster(video_pid, poster_url) when is_binary(poster_url) do
    GenDOM.Node.put(video_pid, :poster, poster_url)
  end

  @doc """
  Gets the intrinsic (natural) video dimensions.

  Returns the actual width and height of the video content in pixels,
  as determined by the video file itself.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement

  ## Returns

  Tuple of `{width, height}` in pixels

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "1920x1080_video.mp4"])
      {natural_width, natural_height} = GenDOM.HTMLVideoElement.get_video_size(video.pid)
      # Returns {1920, 1080} once video metadata loads
  """
  def get_video_size(video_pid) do
    video = GenDOM.Node.get(video_pid)
    {video.video_width, video.video_height}
  end

  @doc """
  Enables or disables picture-in-picture mode.

  Sets the disablePictureInPicture attribute to control whether
  picture-in-picture mode can be requested for this video.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement
  - `disabled` - Boolean indicating if PiP should be disabled

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      
      # Disable picture-in-picture
      GenDOM.HTMLVideoElement.set_picture_in_picture_disabled(video.pid, true)
      
      # Enable picture-in-picture
      GenDOM.HTMLVideoElement.set_picture_in_picture_disabled(video.pid, false)
  """
  def set_picture_in_picture_disabled(video_pid, disabled) when is_boolean(disabled) do
    GenDOM.Node.put(video_pid, :disable_picture_in_picture, disabled)
  end

  @doc """
  Enables or disables auto picture-in-picture mode.

  Sets the autoPictureInPicture attribute to control whether the video
  should automatically enter picture-in-picture mode when the tab becomes inactive.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement  
  - `auto_pip` - Boolean indicating if auto PiP should be enabled

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      
      # Enable auto picture-in-picture
      GenDOM.HTMLVideoElement.set_auto_picture_in_picture(video.pid, true)
  """
  def set_auto_picture_in_picture(video_pid, auto_pip) when is_boolean(auto_pip) do
    GenDOM.Node.put(video_pid, :autopictureinpicture, auto_pip)
  end

  @doc """
  Checks if the video has loaded enough metadata to determine dimensions.

  Returns true if video metadata (including width and height) has been loaded.

  ## Parameters

  - `video_pid` - The PID of the HTMLVideoElement

  ## Returns

  Boolean indicating if video dimensions are available

  ## Examples

      video = GenDOM.HTMLVideoElement.new([src: "video.mp4"])
      
      if GenDOM.HTMLVideoElement.has_video_dimensions?(video.pid) do
        {width, height} = GenDOM.HTMLVideoElement.get_video_size(video.pid)
        # Use video dimensions
      end
  """
  def has_video_dimensions?(video_pid) do
    video = GenDOM.Node.get(video_pid)
    video.video_width > 0 and video.video_height > 0
  end
end