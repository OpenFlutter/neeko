class NeekoPlayerOptions {
  /// if set to true, hides the controls.
  ///
  /// Default = true
  final bool useController;

  /// Define whether to auto play the video after initialization or not.
  ///
  /// Default = true
  final bool autoPlay;

  /// Mutes the player initially
  ///
  /// Default = false
  final bool mute;

  /// Define whether to loop the video
  ///
  /// Default = false
  final bool loop;

  /// Enable drag to seek
  ///
  /// Default = true
  final bool enableDragSeek;

  ///Whether the video is live stream or not.
  ///
  /// Default = false
  final bool isLive;



  /// Shows the fullscreen button.
  ///
  /// Default = true
  final bool showFullScreenButton;

  const NeekoPlayerOptions(
      {this.useController = true,
      this.autoPlay = true,
      this.mute = false,
      this.loop = false,
      this.enableDragSeek = true,
      this.isLive = false,
      this.showFullScreenButton = true
      });
}
