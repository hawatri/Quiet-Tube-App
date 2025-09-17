import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../services/youtube_service.dart';

class AddSongDialog extends StatefulWidget {
  const AddSongDialog({super.key});

  @override
  State<AddSongDialog> createState() => _AddSongDialogState();
}

class _AddSongDialogState extends State<AddSongDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String url) async {
    if (url.trim().isEmpty) {
      _titleController.clear();
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
        setState(() {
          _isLoading = true;
        });

        try {
          final title = await YouTubeService.getVideoTitle(url);
          _titleController.text = title;
        } catch (e) {
          // Silently fail, user can enter title manually
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Invalid URL, ignore
    }
  }

  void _addSong() {
    final playerProvider = context.read<PlayerProvider>();
    final activePlaylist = playerProvider.activePlaylist;
    
    if (activePlaylist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active playlist')),
      );
      return;
    }

    final url = _urlController.text.trim();
    final title = _titleController.text.trim();

    if (url.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both URL and title')),
      );
      return;
    }

    try {
      Uri.parse(url); // Validate URL
      playerProvider.addSongToPlaylist(activePlaylist.id, title, url);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$title" was added to ${activePlaylist.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Song to "${context.read<PlayerProvider>().activePlaylist?.name}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'YouTube URL',
              hintText: 'https://www.youtube.com/watch?v=...',
              border: OutlineInputBorder(),
            ),
            onChanged: _onUrlChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: _isLoading ? 'Fetching title...' : 'Song Title',
              border: const OutlineInputBorder(),
            ),
            enabled: !_isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addSong,
          child: Text(_isLoading ? 'Loading...' : 'Add Song'),
        ),
      ],
    );
  }
}