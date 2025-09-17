import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../widgets/add_song_dialog.dart';

class TrackList extends StatelessWidget {
  const TrackList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final activePlaylist = playerProvider.activePlaylist;
        
        if (activePlaylist == null) {
          return _buildEmptyState(context, 'Welcome to QuietTube', 
              'Select a playlist or create a new one to get started.');
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (MediaQuery.of(context).size.width <= 768)
                      IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activePlaylist.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${activePlaylist.songs.length} ${activePlaylist.songs.length == 1 ? 'song' : 'songs'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSongDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Song'),
                    ),
                  ],
                ),
              ),
              
              // Songs list
              Expanded(
                child: activePlaylist.songs.isEmpty
                    ? _buildEmptyPlaylist(context)
                    : _buildSongsList(context, activePlaylist, playerProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 64,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaylist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.queue_music,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Playlist is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a song to get the party started!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddSongDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Song'),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, playlist, PlayerProvider playerProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: playlist.songs.length,
      itemBuilder: (context, index) {
        final song = playlist.songs[index];
        final isActive = playerProvider.currentTrack?.id == song.id &&
            playerProvider.playingPlaylistId == playlist.id;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 2),
            color: isActive 
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
            child: ListTile(
            leading: IconButton(
              onPressed: () {
                if (isActive) {
                  playerProvider.togglePlay();
                } else {
                  playerProvider.playTrack(playlist.id, index);
                }
              },
              icon: Icon(
                isActive && playerProvider.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: isActive ? Theme.of(context).primaryColor : null,
              ),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : null,
              ),
            ),
            subtitle: Text(
              song.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => playerProvider.playTrack(playlist.id, index),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => playerProvider.queueNext(song),
                  icon: const Icon(Icons.queue),
                  tooltip: 'Play next',
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(context, playlist.id, song.id, song.title),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete song',
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  void _showAddSongDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddSongDialog(),
    );
  }

  void _showDeleteDialog(BuildContext context, String playlistId, String songId, String songTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "$songTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PlayerProvider>().removeSongFromPlaylist(playlistId, songId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}