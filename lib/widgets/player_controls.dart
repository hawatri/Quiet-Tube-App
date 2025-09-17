import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/player_provider.dart';
import '../services/youtube_service.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  String _formatTime(double seconds) {
    if (seconds.isNaN) return '0:00';
    final duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showVolumeDialog(BuildContext context, PlayerProvider playerProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (ctx) {
        return Dialog(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            width: 72,
            height: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volume_up,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: playerProvider.volume,
                      onChanged: playerProvider.setVolume,
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(playerProvider.volume * 100).round()}%'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final currentTrack = playerProvider.currentTrack;
        final thumbnailUrl = currentTrack != null 
            ? YouTubeService.getThumbnailUrl(currentTrack.url)
            : null;

        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Column(
            children: [
              // Progress bar
              if (currentTrack != null)
                Slider(
                  value: playerProvider.progress.clamp(0.0, playerProvider.duration),
                  max: playerProvider.duration > 0 ? playerProvider.duration : 1.0,
                  onChangeStart: (_) {
                    // Pause visual updates while dragging if needed
                  },
                  onChanged: (value) {
                    // Preview position
                    playerProvider.seek(value);
                  },
                  onChangeEnd: (value) {
                    playerProvider.seek(value);
                  },
                ),
              
              // Main controls
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Track info
                      Expanded(
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: thumbnailUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.music_note,
                                            color: Theme.of(context).primaryColor,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.music_note,
                                      color: Theme.of(context).primaryColor,
                                    ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Track details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentTrack?.title ?? 'No song selected',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'QuietTube',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Playback controls (scales down if space is tight)
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Builder(
                            builder: (context) {
                              final double controlIconSize = 18;
                              final double playButtonIconSize = 22;
                              final double controlSpacing = 8;
                              final double playButtonDiameter = 36;

                              final BoxConstraints compactBtn = const BoxConstraints(minWidth: 36, minHeight: 36);
                              const EdgeInsets compactPad = EdgeInsets.all(4);
                              const VisualDensity dense = VisualDensity(horizontal: -2, vertical: -2);

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: currentTrack != null ? playerProvider.toggleShuffle : null,
                                    icon: Icon(
                                      Icons.shuffle,
                                      size: controlIconSize,
                                      color: playerProvider.isShuffled 
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                    constraints: compactBtn,
                                    padding: compactPad,
                                    visualDensity: dense,
                                  ),

                                  SizedBox(width: controlSpacing),

                                  IconButton(
                                    onPressed: currentTrack != null ? playerProvider.playPrevious : null,
                                    icon: Icon(Icons.skip_previous, size: controlIconSize),
                                    constraints: compactBtn,
                                    padding: compactPad,
                                    visualDensity: dense,
                                  ),

                                  SizedBox(width: controlSpacing),

                                  Container(
                                    width: playButtonDiameter,
                                    height: playButtonDiameter,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: currentTrack != null ? playerProvider.togglePlay : null,
                                      icon: Icon(
                                        playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: playButtonIconSize,
                                      ),
                                      constraints: BoxConstraints.tightFor(
                                        width: playButtonDiameter,
                                        height: playButtonDiameter,
                                      ),
                                      padding: EdgeInsets.zero,
                                      visualDensity: dense,
                                    ),
                                  ),

                                  SizedBox(width: controlSpacing),

                                  IconButton(
                                    onPressed: currentTrack != null ? playerProvider.playNext : null,
                                    icon: Icon(Icons.skip_next, size: controlIconSize),
                                    constraints: compactBtn,
                                    padding: compactPad,
                                    visualDensity: dense,
                                  ),

                                  SizedBox(width: controlSpacing),

                                  IconButton(
                                    onPressed: currentTrack != null ? playerProvider.toggleLoop : null,
                                    icon: Icon(
                                      Icons.repeat,
                                      size: controlIconSize,
                                      color: playerProvider.loop 
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                    constraints: compactBtn,
                                    padding: compactPad,
                                    visualDensity: dense,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Volume and time (flexes to available space)
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '${_formatTime(playerProvider.progress)} / ${_formatTime(playerProvider.duration)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            const SizedBox(width: 4),
                            
                            GestureDetector(
                              onTap: () => _showVolumeDialog(context, playerProvider),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.volume_up,
                                size: 12,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Hidden YouTube player
              if (playerProvider.youtubeController != null)
                SizedBox(
                  height: 0,
                  child: YoutubePlayer(
                    controller: playerProvider.youtubeController!,
                    showVideoProgressIndicator: false,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}