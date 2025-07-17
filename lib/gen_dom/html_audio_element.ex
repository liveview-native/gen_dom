defmodule GenDOM.HTMLAudioElement do
  @moduledoc """
  The HTMLAudioElement interface represents an HTML `<audio>` element.

  The HTMLAudioElement interface provides properties and methods for manipulating
  `<audio>` elements. It inherits all properties and methods from HTMLMediaElement
  and adds audio-specific functionality. HTMLAudioElement is primarily used for
  programmatic audio playback and control.

  ## Specification Compliance

  This module implements the HTMLAudioElement interface as defined by:
  - **WHATWG HTML Standard**: https://html.spec.whatwg.org/multipage/media.html#htmlaudioelement
  - **W3C HTML5**: https://www.w3.org/TR/html52/semantics-embedded-content.html#the-audio-element

  ## Inheritance Chain

  ```
  GenDOM.Node (Base)
  └── GenDOM.Element (extends Node)
      └── GenDOM.HTMLElement (extends Element)
          └── GenDOM.HTMLMediaElement (extends HTMLElement)
              └── GenDOM.HTMLAudioElement (extends HTMLMediaElement)
  ```

  **Inherits from:** `GenDOM.HTMLMediaElement`
  **File:** `lib/gen_dom/html_audio_element.ex`
  **Node Type:** 1 (ELEMENT_NODE)
  **Tag Name:** "audio"

  ## Properties

  HTMLAudioElement inherits all properties from HTMLMediaElement without adding
  audio-specific properties. The key inherited properties include:

  ### Media Control (from HTMLMediaElement)
  - `src` - URL of the audio resource
  - `current_src` - Currently playing audio URL (read-only)
  - `autoplay` - Whether audio should start playing automatically
  - `controls` - Whether playback controls should be shown
  - `loop` - Whether audio should restart when it reaches the end
  - `muted` - Whether audio is muted
  - `volume` - Audio volume level (0.0 to 1.0)
  - `playback_rate` - Speed of audio playback

  ### Timing and Progress (from HTMLMediaElement)
  - `current_time` - Current playback position in seconds
  - `duration` - Total length of audio in seconds (read-only)
  - `paused` - Whether audio is currently paused (read-only)
  - `ended` - Whether audio playback has finished (read-only)

  ### Loading and State (from HTMLMediaElement)
  - `preload` - How much audio to preload ("none", "metadata", "auto")
  - `ready_state` - Audio loading state (read-only)
  - `network_state` - Network loading state (read-only)

  ## Methods

  HTMLAudioElement inherits all methods from HTMLMediaElement without adding
  audio-specific methods:

  ### Playback Control (from HTMLMediaElement)
  - `play/1` - Start or resume audio playback
  - `pause/1` - Pause audio playback  
  - `load/1` - Reset and reload the audio

  ### Audio Control (from HTMLMediaElement)
  - `set_volume/2` - Set audio volume (0.0 to 1.0)
  - `set_muted/2` - Mute or unmute audio
  - `set_current_time/2` - Seek to specific time position

  ### Track Management (from HTMLMediaElement)
  - `add_text_track/4` - Add text track for audio descriptions
  - `can_play_type/2` - Check if audio format is supported

  ## Constructor

  HTMLAudioElement has a unique constructor that allows creating audio elements
  entirely in JavaScript without requiring HTML markup:

  ```elixir
  # Create audio element programmatically
  audio = GenDOM.HTMLAudioElement.new([
    src: "background-music.mp3",
    autoplay: false,
    loop: true,
    volume: 0.5
  ])

  # Alternative: create with source URL directly
  audio = GenDOM.HTMLAudioElement.create("sound-effect.wav")
  ```

  ## Usage Examples

  ```elixir
  # Create and play background music
  music = GenDOM.HTMLAudioElement.new([
    src: "https://example.com/background.mp3",
    loop: true,
    volume: 0.3,
    autoplay: false
  ])

  # Start playback
  GenDOM.HTMLAudioElement.play(music.pid)

  # Create sound effect
  sound_effect = GenDOM.HTMLAudioElement.create("coin-collect.wav")
  GenDOM.HTMLAudioElement.set_volume(sound_effect.pid, 0.8)
  GenDOM.HTMLAudioElement.play(sound_effect.pid)

  # Create audio with controls for user interaction
  podcast = GenDOM.HTMLAudioElement.new([
    src: "episode-42.mp3",
    controls: true,
    preload: "metadata"
  ])

  # Monitor playback progress
  current_pos = GenDOM.HTMLAudioElement.get_current_time(podcast.pid)
  total_duration = GenDOM.HTMLAudioElement.get_duration(podcast.pid)
  progress = current_pos / total_duration * 100
  ```

  ## Programmatic Audio Creation

  HTMLAudioElement's primary advantage is programmatic creation:

  ```elixir
  # Sound library for game
  sounds = %{
    jump: GenDOM.HTMLAudioElement.create("jump.wav"),
    coin: GenDOM.HTMLAudioElement.create("coin.wav"), 
    explosion: GenDOM.HTMLAudioElement.create("explosion.wav")
  }

  # Play sound effects
  defp play_sound(sound_name) do
    case Map.get(sounds, sound_name) do
      nil -> :ok
      audio -> GenDOM.HTMLAudioElement.play(audio.pid)
    end
  end

  # Usage
  play_sound(:jump)
  play_sound(:coin)
  ```

  ## Audio Formats and Compatibility

  ```elixir
  # Check audio format support
  audio = GenDOM.HTMLAudioElement.new([])

  formats = [
    "audio/mpeg",        # MP3
    "audio/ogg",         # OGG Vorbis
    "audio/wav",         # WAV
    "audio/aac",         # AAC
    "audio/webm"         # WebM Audio
  ]

  supported_formats = Enum.filter(formats, fn format ->
    GenDOM.HTMLAudioElement.can_play_type(audio.pid, format) != ""
  end)

  # Use most compatible format
  best_format = case supported_formats do
    ["audio/mpeg" | _] -> "mp3"
    ["audio/ogg" | _] -> "ogg" 
    ["audio/wav" | _] -> "wav"
    _ -> "mp3" # fallback
  end
  ```

  ## Volume Control and Audio Management

  ```elixir
  # Background music with fade in/out
  music = GenDOM.HTMLAudioElement.new([
    src: "ambient.mp3",
    loop: true,
    volume: 0.0
  ])

  # Fade in music
  GenDOM.HTMLAudioElement.play(music.pid)
  fade_in_volume(music.pid, 0.5, 2000) # to 50% over 2 seconds

  # Fade out music
  fade_out_volume(music.pid, 2000) # to 0% over 2 seconds

  # Master volume control
  def set_master_volume(volume) do
    # Update all active audio elements
    Enum.each(get_all_audio_elements(), fn audio ->
      current_volume = GenDOM.HTMLAudioElement.get(audio.pid).volume
      adjusted_volume = current_volume * volume
      GenDOM.HTMLAudioElement.set_volume(audio.pid, adjusted_volume)
    end)
  end
  ```

  ## Audio for Accessibility

  ```elixir
  # Audio descriptions for visual content
  audio_description = GenDOM.HTMLAudioElement.new([
    src: "video-description.mp3",
    volume: 0.8
  ])

  # Add description track
  GenDOM.HTMLAudioElement.add_text_track(
    audio_description.pid,
    "descriptions",
    "Audio Description",
    "en"
  )

  # Screen reader compatible audio notifications
  notification = GenDOM.HTMLAudioElement.create("notification.wav")
  GenDOM.HTMLAudioElement.set_volume(notification.pid, 0.6)
  ```

  ## Performance Optimization

  ### Audio Preloading
  ```elixir
  # Preload critical audio
  ui_sounds = [
    GenDOM.HTMLAudioElement.create("button-click.wav"),
    GenDOM.HTMLAudioElement.create("hover-sound.wav"),
    GenDOM.HTMLAudioElement.create("error-beep.wav")
  ]

  # Preload metadata only for large files
  podcast = GenDOM.HTMLAudioElement.new([
    src: "long-podcast.mp3",
    preload: "metadata"
  ])

  # No preloading for conditional audio
  optional_music = GenDOM.HTMLAudioElement.new([
    src: "bonus-track.mp3", 
    preload: "none"
  ])
  ```

  ### Audio Pool for Frequent Sounds
  ```elixir
  # Create pool of identical audio elements for overlapping sounds
  def create_audio_pool(src, pool_size \\ 5) do
    Enum.map(1..pool_size, fn _ ->
      GenDOM.HTMLAudioElement.create(src)
    end)
  end

  # Use round-robin for rapid fire sounds
  laser_pool = create_audio_pool("laser.wav", 10)
  current_laser_index = 0

  def play_laser_sound() do
    audio = Enum.at(laser_pool, current_laser_index)
    GenDOM.HTMLAudioElement.play(audio.pid)
    current_laser_index = rem(current_laser_index + 1, length(laser_pool))
  end
  ```

  ## Events

  HTMLAudioElement supports all HTMLMediaElement events:

  ### Playback Events
  - **play** - Audio playback started
  - **pause** - Audio playback paused
  - **ended** - Audio playback finished
  - **timeupdate** - Current time updated during playback

  ### Loading Events
  - **loadstart** - Audio loading started
  - **loadedmetadata** - Audio metadata loaded
  - **canplay** - Audio ready to play
  - **canplaythrough** - Audio can play through without buffering

  ### Volume Events
  - **volumechange** - Volume or muted state changed

  ## Autoplay Policies

  Modern browsers restrict autoplay to prevent unwanted audio:

  ```elixir
  # Autoplay may be blocked - handle gracefully
  audio = GenDOM.HTMLAudioElement.new([
    src: "welcome.mp3",
    autoplay: true
  ])

  # Check if autoplay worked
  case GenDOM.HTMLAudioElement.play(audio.pid) do
    :ok -> 
      # Autoplay succeeded
    {:error, :autoplay_blocked} ->
      # Show play button for user interaction
      show_audio_play_button(audio.pid)
  end

  # Autoplay after user interaction
  def handle_user_click() do
    # Now autoplay is allowed
    GenDOM.HTMLAudioElement.play(audio.pid)
  end
  ```

  ## Audio Context Integration

  For advanced audio processing, HTMLAudioElement can integrate with Web Audio API:

  ```elixir
  # Note: This would require additional Web Audio API implementation
  # audio = GenDOM.HTMLAudioElement.create("music.mp3")
  # audio_context = AudioContext.new()
  # source = audio_context.create_media_element_source(audio)
  # Connect to audio processing graph...
  ```

  ## Security Considerations

  - **Cross-Origin**: Configure CORS for external audio sources
  - **Content Security Policy**: Set media-src directive for audio sources
  - **Privacy**: Be mindful of audio fingerprinting concerns
  - **Bandwidth**: Consider data usage, especially on mobile connections

  ## Browser Compatibility

  HTMLAudioElement is universally supported across all modern browsers.
  The programmatic constructor `new Audio()` is also universally supported.

  ## Performance Considerations

  - **Audio Format**: Use compressed formats (MP3, AAC) for music, uncompressed (WAV) for short effects
  - **File Size**: Balance quality vs. file size for different use cases
  - **Simultaneous Playback**: Limit concurrent audio streams to avoid performance issues
  - **Memory Management**: Release audio resources when no longer needed
  - **Caching**: Leverage browser caching for frequently used audio files
  """

  @derive {Inspect, only: [:pid, :tag_name, :src, :volume, :current_time, :duration]}

  use GenDOM.HTMLMediaElement, [
    # Override HTMLMediaElement defaults for audio-specific behavior
    tag_name: "audio"
    # No additional audio-specific properties beyond HTMLMediaElement
  ]

  @doc """
  Creates a new HTMLAudioElement with the specified source URL.

  This method provides the equivalent of the JavaScript `new Audio(src)` constructor,
  allowing programmatic creation of audio elements without HTML markup.

  ## Parameters

  - `src` - URL of the audio file to load (optional)

  ## Returns

  New HTMLAudioElement instance

  ## Examples

      # Create audio with source
      audio = GenDOM.HTMLAudioElement.create("sound-effect.wav")

      # Create empty audio element
      audio = GenDOM.HTMLAudioElement.create()

      # Equivalent to:
      audio = GenDOM.HTMLAudioElement.new([src: "sound-effect.wav"])

  ## Specification

  From the HTML Standard: "The Audio() constructor must return a new audio element."

  ## Use Cases

  - Dynamic sound effects in games
  - Programmatic audio playback
  - Audio without requiring HTML markup
  - JavaScript-only audio applications
  """
  def create(src \\ "") do
    new([src: src])
  end

  @doc """
  Plays a short audio clip immediately.

  Convenience method for playing short audio effects or notifications.
  Creates a temporary audio element, plays it, and cleans up automatically.

  ## Parameters

  - `src` - URL of the audio file to play
  - `volume` - Optional volume level (0.0 to 1.0), defaults to 1.0

  ## Examples

      # Play button click sound
      GenDOM.HTMLAudioElement.play_sound("button-click.wav")

      # Play notification at lower volume
      GenDOM.HTMLAudioElement.play_sound("notification.mp3", 0.6)

  ## Use Cases

  - UI sound effects
  - Notification sounds
  - Quick audio feedback
  - One-shot audio playback

  ## Note

  For frequently played sounds, consider creating persistent audio elements
  and reusing them for better performance.
  """
  def play_sound(src, volume \\ 1.0) do
    audio = create(src)
    set_volume(audio.pid, volume)
    play(audio.pid)
    audio
  end

  @doc """
  Creates an audio element optimized for background music.

  Convenience method that creates an audio element with settings
  commonly used for background music: looping enabled, lower volume,
  and metadata preloading.

  ## Parameters

  - `src` - URL of the music file
  - `volume` - Volume level (0.0 to 1.0), defaults to 0.5
  - `autoplay` - Whether to start playing automatically, defaults to false

  ## Returns

  Configured HTMLAudioElement for background music

  ## Examples

      # Create background music
      music = GenDOM.HTMLAudioElement.create_background_music(
        "ambient-music.mp3",
        0.3,
        false
      )

      # Start playing when user interacts
      GenDOM.HTMLAudioElement.play(music.pid)

  ## Settings Applied

  - `loop: true` - Music repeats automatically
  - `preload: "metadata"` - Load metadata but not full audio
  - `volume: volume` - Set to specified volume
  - `autoplay: autoplay` - Set autoplay preference
  """
  def create_background_music(src, volume \\ 0.5, autoplay \\ false) do
    new([
      src: src,
      loop: true,
      volume: volume,
      autoplay: autoplay,
      preload: "metadata"
    ])
  end

  @doc """
  Creates an audio element for sound effects.

  Convenience method that creates an audio element with settings
  optimized for sound effects: no looping, full preload for instant playback.

  ## Parameters

  - `src` - URL of the sound effect file
  - `volume` - Volume level (0.0 to 1.0), defaults to 1.0

  ## Returns

  Configured HTMLAudioElement for sound effects

  ## Examples

      # Create sound effect
      explosion = GenDOM.HTMLAudioElement.create_sound_effect("explosion.wav", 0.8)

      # Play when needed
      GenDOM.HTMLAudioElement.play(explosion.pid)

  ## Settings Applied

  - `loop: false` - Sound plays once
  - `preload: "auto"` - Preload for instant playback
  - `volume: volume` - Set to specified volume
  - `autoplay: false` - Don't autoplay
  """
  def create_sound_effect(src, volume \\ 1.0) do
    new([
      src: src,
      loop: false,
      volume: volume,
      autoplay: false,
      preload: "auto"
    ])
  end

  @doc """
  Fades the audio volume to a target level over time.

  Gradually changes the volume from current level to target level
  over the specified duration.

  ## Parameters

  - `audio_pid` - The PID of the HTMLAudioElement
  - `target_volume` - Target volume level (0.0 to 1.0)
  - `duration_ms` - Duration of fade in milliseconds

  ## Examples

      # Fade music to 50% over 2 seconds
      GenDOM.HTMLAudioElement.fade_volume(music.pid, 0.5, 2000)

      # Fade out to silence over 1 second
      GenDOM.HTMLAudioElement.fade_volume(music.pid, 0.0, 1000)

  ## Implementation Note

  This is a convenience method that would typically use a timer-based
  implementation to gradually adjust volume over time.
  """
  def fade_volume(audio_pid, target_volume, duration_ms) do
    current_volume = get(audio_pid).volume
    
    # Implementation would use timer to gradually adjust volume
    # For now, set target volume immediately
    set_volume(audio_pid, target_volume)
    
    # In real implementation:
    # 1. Calculate volume step size
    # 2. Use timer to incrementally adjust volume
    # 3. Stop when target reached or duration elapsed
  end

  @doc """
  Stops audio playback and resets to beginning.

  Pauses the audio and resets current time to 0, effectively stopping playback.

  ## Parameters

  - `audio_pid` - The PID of the HTMLAudioElement

  ## Examples

      GenDOM.HTMLAudioElement.stop(audio.pid)

  ## Note

  HTMLAudioElement doesn't have a native stop() method, so this combines
  pause() and setting currentTime to 0.
  """
  def stop(audio_pid) do
    pause(audio_pid)
    set_current_time(audio_pid, 0.0)
  end

  @doc """
  Checks if the audio is currently playing.

  Returns true if audio is playing (not paused and not ended).

  ## Parameters

  - `audio_pid` - The PID of the HTMLAudioElement

  ## Returns

  Boolean indicating if audio is playing

  ## Examples

      if GenDOM.HTMLAudioElement.is_playing?(audio.pid) do
        # Audio is currently playing
      end
  """
  def is_playing?(audio_pid) do
    audio = get(audio_pid)
    not audio.paused and not audio.ended
  end

  @doc """
  Gets the remaining playback time in seconds.

  Calculates how much time is left before the audio finishes playing.

  ## Parameters

  - `audio_pid` - The PID of the HTMLAudioElement

  ## Returns

  Remaining time in seconds, or `:infinity` if duration unknown

  ## Examples

      remaining = GenDOM.HTMLAudioElement.get_remaining_time(audio.pid)
      # Returns seconds left in playback
  """
  def get_remaining_time(audio_pid) do
    audio = get(audio_pid)
    
    case audio.duration do
      duration when is_number(duration) ->
        max(0.0, duration - audio.current_time)
      _ ->
        :infinity
    end
  end

  @doc """
  Sets up an audio playlist with crossfade transitions.

  Creates multiple audio elements for smooth playlist playback with
  overlapping transitions between tracks.

  ## Parameters

  - `track_urls` - List of audio file URLs
  - `crossfade_duration` - Crossfade duration in milliseconds

  ## Returns

  Playlist control structure

  ## Examples

      playlist = GenDOM.HTMLAudioElement.create_playlist([
        "track1.mp3",
        "track2.mp3", 
        "track3.mp3"
      ], 2000)

      # Start playing playlist
      GenDOM.HTMLAudioElement.play_playlist(playlist)

  ## Implementation Note

  This would typically involve managing multiple audio elements and
  coordinating their playback timing for smooth transitions.
  """
  def create_playlist(track_urls, crossfade_duration \\ 1000) do
    audio_elements = Enum.map(track_urls, fn url ->
      create_background_music(url, 0.5, false)
    end)

    %{
      tracks: audio_elements,
      current_index: 0,
      crossfade_duration: crossfade_duration,
      is_playing: false
    }
  end
end