import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../services/youtube_service.dart';

class SongSearchBar extends StatefulWidget {
  const SongSearchBar({super.key});

  @override
  State<SongSearchBar> createState() => _SongSearchBarState();
}

class _SongSearchBarState extends State<SongSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    if (_isYouTubeUrl(query)) {
      setState(() {
        _searchResults = [
          {
            'type': 'youtube',
            'title': 'Play from YouTube',
            'url': query,
          }
        ];
      });
      return;
    }

    // Search in existing playlists
    final playerProvider = context.read<PlayerProvider>();
    final results = <Map<String, dynamic>>[];
    
    for (final playlist in playerProvider.playlists) {
      for (final song in playlist.songs) {
        if (song.title.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'type': 'song',
            'song': song,
            'playlist': playlist,
          });
        }
      }
    }

    setState(() {
      _searchResults = results.take(5).toList();
    });
  }

  bool _isYouTubeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
    } catch (e) {
      return false;
    }
  }

  void _onResultTap(Map<String, dynamic> result) async {
    final playerProvider = context.read<PlayerProvider>();
    
    if (result['type'] == 'youtube') {
      final activePlaylist = playerProvider.activePlaylist;
      if (activePlaylist == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a playlist first')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final title = await YouTubeService.getVideoTitle(result['url']);
        final song = playerProvider.addSongToPlaylist(
          activePlaylist.id,
          title,
          result['url'],
        );
        
        if (song != null) {
          final songIndex = activePlaylist.songs.length; // New song will be at the end
          playerProvider.playTrack(activePlaylist.id, songIndex);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Now playing: $title')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add song from YouTube')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (result['type'] == 'song') {
      final song = result['song'];
      final playlist = result['playlist'];
      final songIndex = playlist.songs.indexWhere((s) => s.id == song.id);
      
      if (songIndex != -1) {
        playerProvider.playTrack(playlist.id, songIndex);
      }
    }

    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search or paste YouTube URL...',
            prefixIcon: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: _onSearchChanged,
          enabled: !_isLoading,
        ),
        
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                
                if (result['type'] == 'youtube') {
                  return ListTile(
                    leading: const Icon(Icons.play_circle, color: Colors.red),
                    title: const Text('Play from YouTube'),
                    onTap: () => _onResultTap(result),
                  );
                } else {
                  final song = result['song'];
                  final playlist = result['playlist'];
                  
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      playlist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _onResultTap(result),
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}