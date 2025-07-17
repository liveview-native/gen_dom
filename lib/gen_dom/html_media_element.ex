defmodule GenDOM.HTMLMediaElement do
  @moduledoc """
  The HTMLMediaElement interface represents any HTML media element.

  The HTMLMediaElement interface adds to HTMLElement the properties and methods needed to support
  basic media-related capabilities that are common to audio and video. It serves as the base class
  for HTMLVideoElement and HTMLAudioElement, providing shared functionality for media playback,
  timing, volume control, and track management.

  ## Specification Compliance

  This module implements the HTMLMediaElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/media.html#htmlmediaelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/semantics-embedded-content.html#htmlmediaelement

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLMediaElement (extends HTMLElement)
              ├── GenDOM.HTMLVideoElement (extends HTMLMediaElement)
              └── GenDOM.HTMLAudioElement (extends HTMLMediaElement)
  ```

  **Inherits from:** `GenDOM.HTMLElement`
  **File:** `lib/gen_dom/html_media_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)

  ## Properties

  ### Playback Control
  - `autoplay` - Whether media should start playing automatically
  - `controls` - Whether playback controls should be shown
  - `loop` - Whether media should restart when it reaches the end
  - `muted` - Whether audio is muted
  - `default_muted` - Default mute state
  - `preload` - How much media to preload ("none", "metadata", "auto")
  - `playback_rate` - Speed of media playback (1.0 = normal speed)
  - `default_playback_rate` - Default playback rate
  - `preserves_pitch` - Whether audio pitch is preserved during rate changes

  ### Media Source and Content
  - `src` - URL of the media resource
  - `current_src` - Currently playing media URL (read-only)

  ### Timing and Progress
  - `current_time` - Current playback position in seconds
  - `duration` - Total length of media in seconds (read-only)
  - `buffered` - Time ranges that have been buffered (read-only)
  - `seekable` - Time ranges that are seekable (read-only)
  - `played` - Time ranges that have been played (read-only)

  ### State Properties
  - `paused` - Whether media is currently paused (read-only)
  - `ended` - Whether media playback has finished (read-only)
  - `seeking` - Whether media is currently seeking (read-only)
  - `ready_state` - Media loading state (read-only)
  - `network_state` - Network loading state (read-only)

  ### Volume and Audio
  - `volume` - Audio volume level (0.0 to 1.0)

  ### Track Management
  - `audio_tracks` - Available audio tracks (read-only)
  - `video_tracks` - Available video tracks (read-only)
  - `text_tracks` - Available text tracks for subtitles/captions (read-only)

  ### Cross-Origin and Security
  - `cross_origin` - CORS settings for media requests
  - `media_keys` - MediaKeys object for encrypted media

  ### Error Handling
  - `error` - MediaError object if loading failed (read-only)

  ## Constants

  ### Network States
  - `NETWORK_EMPTY` (0) - No source assigned
  - `NETWORK_IDLE` (1) - Source assigned but not loading
  - `NETWORK_LOADING` (2) - Currently loading
  - `NETWORK_NO_SOURCE` (3) - No suitable source found

  ### Ready States
  - `HAVE_NOTHING` (0) - No data available
  - `HAVE_METADATA` (1) - Metadata loaded but no data
  - `HAVE_CURRENT_DATA` (2) - Data for current position available
  - `HAVE_FUTURE_DATA` (3) - Data for current and future positions
  - `HAVE_ENOUGH_DATA` (4) - Enough data to play through

  ## Methods

  ### Playback Control
  - `play/1` - Start or resume media playback
  - `pause/1` - Pause media playback
  - `load/1` - Reset and reload the media

  ### Seeking and Timing
  - `fast_seek/2` - Quickly seek to a specific time

  ### Track Management
  - `add_text_track/4` - Add a text track for subtitles or captions
  - `can_play_type/2` - Check if media type is supported

  ### Inherited Methods
  All methods from HTMLElement, Element, and Node are available.

  ## Usage Examples

  ```elixir
  # Create a basic media element (usually done via video/audio elements)
  media = GenDOM.HTMLMediaElement.new([
    src: "https://example.com/video.mp4",
    controls: true,
    autoplay: false,
    volume: 0.8
  ])

  # Control playback
  GenDOM.HTMLMediaElement.play(media.pid)
  GenDOM.HTMLMediaElement.pause(media.pid)

  # Seek to specific time
  GenDOM.HTMLMediaElement.set_current_time(media.pid, 30.5)

  # Check playback state
  state = GenDOM.HTMLMediaElement.get(media.pid)
  if state.paused do
    # Media is paused
  end

  # Set volume
  GenDOM.HTMLMediaElement.set_volume(media.pid, 0.5)
  ```

  ## Media Loading and Buffering

  Media elements progress through several loading states:

  ```elixir
  media_state = GenDOM.HTMLMediaElement.get(media.pid)
  
  case media_state.ready_state do
    0 -> # HAVE_NOTHING - No data
    1 -> # HAVE_METADATA - Duration and dimensions known
    2 -> # HAVE_CURRENT_DATA - Can play current position
    3 -> # HAVE_FUTURE_DATA - Can play a bit into future
    4 -> # HAVE_ENOUGH_DATA - Can play through to end
  end
  ```

  ## Events

  HTMLMediaElement supports extensive media events:

  ### Loading Events
  - **loadstart** - Loading has begun
  - **progress** - Loading is progressing
  - **loadedmetadata** - Metadata has loaded
  - **loadeddata** - First frame has loaded
  - **canplay** - Playback can begin
  - **canplaythrough** - Can play through without buffering

  ### Playback Events
  - **play** - Playback has started
  - **pause** - Playback has been paused
  - **playing** - Playback is ready after pause/buffering
  - **ended** - Playback has finished
  - **seeking** - Seeking operation has begun
  - **seeked** - Seeking operation has completed

  ### State Change Events
  - **timeupdate** - Current time has changed
  - **durationchange** - Duration has changed
  - **ratechange** - Playback rate has changed
  - **volumechange** - Volume has changed

  ### Error Events
  - **error** - An error occurred
  - **stalled** - Data loading has stalled
  - **suspend** - Loading has been suspended
  - **abort** - Loading was aborted

  ## Volume Control

  ```elixir
  # Set volume (0.0 to 1.0)
  GenDOM.HTMLMediaElement.set_volume(media.pid, 0.75)

  # Mute/unmute
  GenDOM.HTMLMediaElement.set_muted(media.pid, true)
  GenDOM.HTMLMediaElement.set_muted(media.pid, false)

  # Check if muted
  is_muted = GenDOM.HTMLMediaElement.get(media.pid).muted
  ```

  ## Playback Rate Control

  ```elixir
  # Double speed playback
  GenDOM.HTMLMediaElement.set_playback_rate(media.pid, 2.0)

  # Half speed playback
  GenDOM.HTMLMediaElement.set_playback_rate(media.pid, 0.5)

  # Preserve pitch during rate changes
  GenDOM.HTMLMediaElement.set_preserves_pitch(media.pid, true)
  ```

  ## Text Tracks and Subtitles

  ```elixir
  # Add subtitle track
  track = GenDOM.HTMLMediaElement.add_text_track(
    media.pid,
    "subtitles",
    "English Subtitles",
    "en"
  )

  # Add caption track
  caption_track = GenDOM.HTMLMediaElement.add_text_track(
    media.pid,
    "captions", 
    "English Captions",
    "en"
  )
  ```

  ## Cross-Origin Media

  ```elixir
  # Enable CORS for cross-origin media
  media = GenDOM.HTMLMediaElement.new([
    src: "https://external.com/video.mp4",
    cross_origin: "anonymous"
  ])
  ```

  ## Performance Considerations

  - **Preloading**: Use `preload` attribute to control initial loading
  - **Buffering**: Monitor `buffered` property for buffer health
  - **Seeking**: Use `fast_seek` for performance-optimized seeking
  - **Format Support**: Check `can_play_type` before setting sources

  ## Security Considerations

  - **CORS**: Configure cross-origin settings for external media
  - **Content Security Policy**: Set media-src directive appropriately
  - **Encrypted Media**: Use MediaKeys for DRM-protected content

  ## Browser Compatibility

  HTMLMediaElement is universally supported across modern browsers.
  Some advanced features like MediaKeys may have limited support.
  """

  @derive {Inspect, only: [:pid, :tag_name, :src, :current_time, :duration, :paused, :volume]}

  use GenDOM.HTMLElement, [
    # Media source and content
    src: "",
    current_src: "", # read-only

    # Playback control
    autoplay: false,
    controls: false,
    loop: false,
    muted: false,
    default_muted: false,
    preload: "metadata", # "none" | "metadata" | "auto"
    playback_rate: 1.0,
    default_playback_rate: 1.0,
    preserves_pitch: true,

    # Timing and progress (read-only properties set by implementation)
    current_time: 0.0,
    duration: 0.0, # NaN when unknown
    buffered: [], # TimeRanges
    seekable: [], # TimeRanges
    played: [], # TimeRanges

    # State properties (read-only)
    paused: true,
    ended: false,
    seeking: false,
    ready_state: 0, # HAVE_NOTHING
    network_state: 0, # NETWORK_EMPTY

    # Volume and audio
    volume: 1.0,

    # Track management (read-only)
    audio_tracks: [],
    video_tracks: [],
    text_tracks: [],

    # Cross-origin and security
    cross_origin: nil, # nil | "anonymous" | "use-credentials"
    media_keys: nil,

    # Error handling
    error: nil # MediaError object
  ]

  # Network state constants
  @network_empty 0
  @network_idle 1
  @network_loading 2
  @network_no_source 3

  # Ready state constants
  @have_nothing 0
  @have_metadata 1
  @have_current_data 2
  @have_future_data 3
  @have_enough_data 4

  @doc """
  Network state constant: No source assigned.
  """
  def network_empty, do: @network_empty

  @doc """
  Network state constant: Source assigned but not loading.
  """
  def network_idle, do: @network_idle

  @doc """
  Network state constant: Currently loading.
  """
  def network_loading, do: @network_loading

  @doc """
  Network state constant: No suitable source found.
  """
  def network_no_source, do: @network_no_source

  @doc """
  Ready state constant: No data available.
  """
  def have_nothing, do: @have_nothing

  @doc """
  Ready state constant: Metadata loaded but no data.
  """
  def have_metadata, do: @have_metadata

  @doc """
  Ready state constant: Data for current position available.
  """
  def have_current_data, do: @have_current_data

  @doc """
  Ready state constant: Data for current and future positions.
  """
  def have_future_data, do: @have_future_data

  @doc """
  Ready state constant: Enough data to play through.
  """
  def have_enough_data, do: @have_enough_data

  @doc """
  Starts or resumes media playback.

  This method implements the HTMLMediaElement `play()` specification. It begins playback
  of the media if it's paused, or resumes playback if it was previously paused.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement to play

  ## Returns

  Returns `:ok` if playback starts successfully, or `{:error, reason}` if it fails.

  ## Examples

      media = GenDOM.HTMLMediaElement.new([src: "video.mp4"])
      result = GenDOM.HTMLMediaElement.play(media.pid)
      case result do
        :ok -> # Playback started
        {:error, reason} -> # Playback failed
      end

  ## Specification

  From the HTML Standard: "The play() method must run the play the media steps."

  ## Events

  - Fires 'play' event when playback starts
  - Fires 'playing' event when playback is ready

  ## Autoplay Policy

  Modern browsers may block autoplay. User interaction may be required
  before play() will succeed.
  """
  def play(media_pid) do
    # Implementation would:
    # 1. Check if media source is valid
    # 2. Start/resume playback
    # 3. Update paused state
    # 4. Fire appropriate events
    GenDOM.Node.put(media_pid, :paused, false)
    :ok
  end

  @doc """
  Pauses media playback.

  This method implements the HTMLMediaElement `pause()` specification. It pauses
  playback of the media if it's currently playing.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement to pause

  ## Examples

      GenDOM.HTMLMediaElement.pause(media.pid)

  ## Specification

  From the HTML Standard: "The pause() method must run the pause the media steps."

  ## Events

  - Fires 'pause' event when playback pauses
  """
  def pause(media_pid) do
    GenDOM.Node.put(media_pid, :paused, true)
    # Implementation would fire pause event
  end

  @doc """
  Resets and reloads the media element.

  This method implements the HTMLMediaElement `load()` specification. It resets
  the media element to its initial state and begins loading the media again.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement to reload

  ## Examples

      GenDOM.HTMLMediaElement.load(media.pid)

  ## Specification

  From the HTML Standard: "The load() method must run the media element load algorithm."

  ## Side Effects

  - Resets current time to 0
  - Clears buffered ranges
  - Fires 'loadstart' event
  - May fire 'abort' event if loading was in progress
  """
  def load(media_pid) do
    GenDOM.Node.merge(media_pid, %{
      current_time: 0.0,
      paused: true,
      ended: false,
      seeking: false,
      buffered: [],
      played: [],
      ready_state: @have_nothing,
      network_state: @network_loading
    })
    # Implementation would start loading process
  end

  @doc """
  Quickly seeks to a specific time in the media.

  This method implements the HTMLMediaElement `fastSeek()` specification. It seeks
  to the specified time, potentially with reduced accuracy for better performance.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `time` - Time to seek to in seconds

  ## Examples

      # Seek to 30 seconds
      GenDOM.HTMLMediaElement.fast_seek(media.pid, 30.0)

  ## Specification

  From the HTML Standard: "The fastSeek() method must run the seek algorithm with
  the approximate-for-speed flag set."

  ## Performance

  This method may sacrifice accuracy for speed, making it suitable for scrubbing
  operations where exact frame accuracy is not required.
  """
  def fast_seek(media_pid, time) when is_number(time) do
    set_current_time(media_pid, time)
    # Implementation would perform optimized seeking
  end

  @doc """
  Adds a text track for subtitles, captions, or descriptions.

  This method implements the HTMLMediaElement `addTextTrack()` specification.
  It creates and returns a new TextTrack object.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `kind` - Type of track ("subtitles", "captions", "descriptions", "chapters", "metadata")
  - `label` - Human-readable label for the track (optional)
  - `language` - Language of the track (optional)

  ## Returns

  Returns a TextTrack object.

  ## Examples

      # Add subtitle track
      track = GenDOM.HTMLMediaElement.add_text_track(
        media.pid,
        "subtitles",
        "English Subtitles",
        "en"
      )

      # Add caption track
      captions = GenDOM.HTMLMediaElement.add_text_track(
        media.pid,
        "captions",
        "English Captions",
        "en"
      )

  ## Specification

  From the HTML Standard: "The addTextTrack() method must create and return a new
  TextTrack object."
  """
  def add_text_track(media_pid, kind, label \\ "", language \\ "") 
      when kind in ["subtitles", "captions", "descriptions", "chapters", "metadata"] do
    track = %{
      kind: kind,
      label: label,
      language: language,
      mode: "disabled", # "disabled" | "hidden" | "showing"
      cues: []
    }
    
    media = GenDOM.Node.get(media_pid)
    updated_tracks = [track | media.text_tracks]
    GenDOM.Node.put(media_pid, :text_tracks, updated_tracks)
    
    track
  end

  @doc """
  Checks if the media element can play the specified media type.

  This method implements the HTMLMediaElement `canPlayType()` specification.
  It returns a string indicating the likelihood that the media type can be played.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `media_type` - MIME type string to check

  ## Returns

  - `""` (empty string) - Cannot play this type
  - `"maybe"` - Might be able to play this type
  - `"probably"` - Likely can play this type

  ## Examples

      # Check video format support
      result = GenDOM.HTMLMediaElement.can_play_type(media.pid, "video/mp4")
      case result do
        "probably" -> # Strong support
        "maybe" -> # Possible support  
        "" -> # No support
      end

      # Check codec support
      result = GenDOM.HTMLMediaElement.can_play_type(
        media.pid, 
        "video/mp4; codecs=\\"avc1.42E01E, mp4a.40.2\\""
      )

  ## Specification

  From the HTML Standard: "The canPlayType() method must return the empty string
  if type is a type that the user agent knows it cannot render."
  """
  def can_play_type(_media_pid, media_type) when is_binary(media_type) do
    # Implementation would check against supported formats
    # For now, return basic support indication
    cond do
      String.contains?(media_type, "video/mp4") -> "probably"
      String.contains?(media_type, "video/webm") -> "probably"
      String.contains?(media_type, "audio/mp3") -> "probably"
      String.contains?(media_type, "audio/ogg") -> "maybe"
      true -> ""
    end
  end

  @doc """
  Sets the current playback position.

  Updates the currentTime property and seeks to the specified position.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `time` - Time position in seconds

  ## Examples

      # Seek to 2 minutes 30 seconds
      GenDOM.HTMLMediaElement.set_current_time(media.pid, 150.0)
  """
  def set_current_time(media_pid, time) when is_number(time) do
    # Clamp time to valid range
    media = GenDOM.Node.get(media_pid)
    duration = media.duration || 0.0
    clamped_time = max(0.0, min(time, duration))
    
    GenDOM.Node.put(media_pid, :current_time, clamped_time)
    # Implementation would trigger seeking and fire events
  end

  @doc """
  Sets the audio volume level.

  Updates the volume property. Volume must be between 0.0 (silent) and 1.0 (full volume).

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `volume` - Volume level (0.0 to 1.0)

  ## Examples

      # Set to half volume
      GenDOM.HTMLMediaElement.set_volume(media.pid, 0.5)

      # Set to full volume
      GenDOM.HTMLMediaElement.set_volume(media.pid, 1.0)
  """
  def set_volume(media_pid, volume) when is_number(volume) do
    # Clamp volume to valid range
    clamped_volume = max(0.0, min(volume, 1.0))
    GenDOM.Node.put(media_pid, :volume, clamped_volume)
    # Implementation would fire volumechange event
  end

  @doc """
  Sets the muted state of the media.

  Controls whether audio output is muted regardless of volume setting.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `muted` - Boolean indicating muted state

  ## Examples

      # Mute audio
      GenDOM.HTMLMediaElement.set_muted(media.pid, true)

      # Unmute audio
      GenDOM.HTMLMediaElement.set_muted(media.pid, false)
  """
  def set_muted(media_pid, muted) when is_boolean(muted) do
    GenDOM.Node.put(media_pid, :muted, muted)
    # Implementation would fire volumechange event
  end

  @doc """
  Sets the playback rate (speed).

  Controls how fast the media plays. 1.0 is normal speed, 2.0 is double speed, 
  0.5 is half speed, etc.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `rate` - Playback rate multiplier

  ## Examples

      # Double speed
      GenDOM.HTMLMediaElement.set_playback_rate(media.pid, 2.0)

      # Half speed
      GenDOM.HTMLMediaElement.set_playback_rate(media.pid, 0.5)

      # Reverse playback (if supported)
      GenDOM.HTMLMediaElement.set_playback_rate(media.pid, -1.0)
  """
  def set_playback_rate(media_pid, rate) when is_number(rate) do
    GenDOM.Node.put(media_pid, :playback_rate, rate)
    # Implementation would fire ratechange event
  end

  @doc """
  Sets whether to preserve audio pitch during rate changes.

  When true, audio pitch remains constant despite playback rate changes.
  When false, pitch changes with playback rate (chipmunk/slowdown effect).

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `preserve` - Boolean indicating whether to preserve pitch

  ## Examples

      # Preserve pitch during speed changes
      GenDOM.HTMLMediaElement.set_preserves_pitch(media.pid, true)

      # Allow pitch to change with speed
      GenDOM.HTMLMediaElement.set_preserves_pitch(media.pid, false)
  """
  def set_preserves_pitch(media_pid, preserve) when is_boolean(preserve) do
    GenDOM.Node.put(media_pid, :preserves_pitch, preserve)
  end

  @doc """
  Sets the media source URL.

  Updates the src attribute and initiates loading of the new media.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement
  - `url` - URL of the media resource

  ## Examples

      GenDOM.HTMLMediaElement.set_src(media.pid, "https://example.com/video.mp4")
  """
  def set_src(media_pid, url) when is_binary(url) do
    GenDOM.Node.put(media_pid, :src, url)
    # Implementation would trigger load() automatically
    load(media_pid)
  end

  @doc """
  Gets the current playback position in seconds.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement

  ## Returns

  Current time in seconds

  ## Examples

      current_pos = GenDOM.HTMLMediaElement.get_current_time(media.pid)
  """
  def get_current_time(media_pid) do
    media = GenDOM.Node.get(media_pid)
    media.current_time
  end

  @doc """
  Gets the total duration of the media in seconds.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement

  ## Returns

  Duration in seconds, or `:infinity` if unknown

  ## Examples

      duration = GenDOM.HTMLMediaElement.get_duration(media.pid)
  """
  def get_duration(media_pid) do
    media = GenDOM.Node.get(media_pid)
    media.duration
  end

  @doc """
  Checks if the media is currently paused.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement

  ## Returns

  Boolean indicating paused state

  ## Examples

      if GenDOM.HTMLMediaElement.is_paused?(media.pid) do
        # Media is paused
      end
  """
  def is_paused?(media_pid) do
    media = GenDOM.Node.get(media_pid)
    media.paused
  end

  @doc """
  Checks if the media has ended.

  ## Parameters

  - `media_pid` - The PID of the HTMLMediaElement

  ## Returns

  Boolean indicating if playback has finished

  ## Examples

      if GenDOM.HTMLMediaElement.has_ended?(media.pid) do
        # Playback completed
      end
  """
  def has_ended?(media_pid) do
    media = GenDOM.Node.get(media_pid)
    media.ended
  end
end
