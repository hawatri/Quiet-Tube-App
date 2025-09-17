import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/player_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/song_search_bar.dart';

class PlaylistSidebar extends StatefulWidget {
  const PlaylistSidebar({super.key});

  @override
  State<PlaylistSidebar> createState() => _PlaylistSidebarState();
}

class _PlaylistSidebarState extends State<PlaylistSidebar> {
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: _playlistNameController,
          decoration: const InputDecoration(
            hintText: 'My Awesome Mix',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => _createPlaylist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createPlaylist,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createPlaylist() {
    final name = _playlistNameController.text.trim();
    if (name.isNotEmpty) {
      context.read<PlayerProvider>().createPlaylist(name);
      _playlistNameController.clear();
      Navigator.pop(context);
    }
  }

  void _exportAllPlaylists() {
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.exportPlaylists();
    
    // In a real app, you'd save this to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality would save file here')),
    );
  }

  void _importPlaylists() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['music', 'json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        context.read<PlayerProvider>().importPlaylists(jsonString);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Playlists imported successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing playlists: $e')),
        );
      }
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System'),
              leading: const Icon(Icons.auto_mode),
              onTap: () {
                context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QuietTube',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _showThemeDialog,
                      icon: Icon(
                        context.watch<ThemeProvider>().isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const SongSearchBar(),
                const SizedBox(height: 16),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: ElevatedButton.icon(
                          onPressed: _showCreatePlaylistDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('New Playlist'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _exportAllPlaylists,
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Export'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _importPlaylists,
                            icon: const Icon(Icons.folder_open, size: 16),
                            label: const Text('Import'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Playlists list
          Expanded(
            child: Consumer<PlayerProvider>(
              builder: (context, playerProvider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: playerProvider.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playerProvider.playlists[index];
                    final isActive = playlist.id == playerProvider.activePlaylistId;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: isActive 
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : null,
                      child: ListTile(
                        leading: const Icon(Icons.queue_music),
                        title: Text(
                          playlist.name,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : null,
                          ),
                        ),
                        subtitle: Text('${playlist.songs.length} songs'),
                        onTap: () => playerProvider.selectPlaylist(playlist.id),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                if (playlist.songs.isNotEmpty) {
                                  playerProvider.playTrack(playlist.id, 0);
                                }
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.play_arrow),
                                  SizedBox(width: 8),
                                  Text('Play'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => _showRenameDialog(playlist.id, playlist.name),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Rename'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                playerProvider.exportPlaylists(playlist.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Export functionality would save file here')),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.download),
                                  SizedBox(width: 8),
                                  Text('Export'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => _showDeleteDialog(playlist.id, playlist.name),
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(String playlistId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                context.read<PlayerProvider>().updatePlaylistName(playlistId, newName);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String playlistId, String playlistName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "$playlistName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PlayerProvider>().deletePlaylist(playlistId);
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