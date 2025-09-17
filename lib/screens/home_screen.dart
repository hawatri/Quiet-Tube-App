import 'package:flutter/material.dart';
import '../widgets/playlist_sidebar.dart';
import '../widgets/track_list.dart';
import '../widgets/player_controls.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= 768;
    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('QuietTube'),
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                  tooltip: 'Open playlists',
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Animated background
          const AnimatedBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar for larger screens
                      if (MediaQuery.of(context).size.width > 768)
                        const SizedBox(
                          width: 300,
                          child: PlaylistSidebar(),
                        ),
                      
                      // Main content area
                      const Expanded(
                        child: TrackList(),
                      ),
                    ],
                  ),
                ),
                
                // Player controls at bottom
                const PlayerControls(),
              ],
            ),
          ),
        ],
      ),
      
      // Drawer for mobile
      drawer: MediaQuery.of(context).size.width <= 768 
          ? const Drawer(child: PlaylistSidebar())
          : null,
    );
  }
}