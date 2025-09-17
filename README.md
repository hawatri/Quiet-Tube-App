# 🎵 QuietTube - Flutter

**Listen to YouTube music without distractions - A beautiful, minimalist music player built with Flutter**

QuietTube transforms YouTube videos into a clean, audio-focused listening experience. Create playlists, manage your music library, and enjoy seamless playback with a stunning interface designed for music lovers.

## ✨ Features

### 🎶 Core Music Experience
- **Audio-Only Playback**: Extract and play audio from YouTube videos without video distractions
- **Smart Playlist Management**: Create, organize, and manage custom music libraries
- **Advanced Playback Controls**: Play, pause, skip, shuffle, repeat, and volume control
- **Background Playback**: Continue listening even when the screen is off (mobile optimized)
- **Queue Management**: Add songs to play next with smart queueing

### 🎨 Beautiful Design
- **Material Design 3**: Modern, clean interface following Material Design principles
- **Animated Background**: Dynamic, flowing gradients that respond to your music
- **Responsive Design**: Optimized for all devices - mobile, tablet, and desktop
- **Dark/Light Theme**: Automatic theme switching with system preference support
- **Album Art Integration**: YouTube thumbnails as dynamic backgrounds

### 🔍 Smart Features
- **Instant Search**: Search your library or paste YouTube URLs directly
- **Auto-Title Fetching**: Automatically retrieves video titles from YouTube
- **Cross-Platform**: Runs on Android, iOS, and desktop platforms
- **Local Storage**: All data stored locally - no cloud dependencies

### 💾 Data Management
- **Local Storage**: All data stored locally using SharedPreferences
- **Import/Export**: Save and share playlists as `.music` files
- **Backup & Restore**: Easy playlist backup and migration
- **Data Validation**: Robust error handling and data integrity

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- For iOS development: Xcode

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/quiettube-flutter.git
   cd quiettube-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 How to Use

### Creating Your First Playlist
1. Tap **"New Playlist"** in the sidebar
2. Give your playlist a memorable name
3. Start adding songs by pasting YouTube URLs or searching your library

### Adding Songs
- **From YouTube**: Paste any YouTube URL in the search bar
- **Quick Add**: Use the "Add Song" button in any playlist
- **Bulk Import**: Import existing playlists from `.music` files

### Playback Controls
- **Tap to Play**: Tap any song to start playback
- **Skip Controls**: Use previous/next buttons
- **Volume Control**: Adjust playback volume with slider
- **Progress Control**: Seek to any position in the song

### Managing Playlists
- **Rename**: Long press any playlist to rename
- **Export**: Download playlists as `.music` files
- **Delete**: Remove playlists you no longer need
- **Reorder**: Drag and drop songs within playlists

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+ with Dart
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **YouTube Integration**: youtube_player_flutter
- **File Operations**: file_picker, path_provider
- **Background Playback**: wakelock_plus, audio_session
- **UI Components**: Material Design 3 components

## 🎨 Design Philosophy

QuietTube follows a **"calm technology"** approach:

- **Minimal Distractions**: Clean interface focused on music
- **Intuitive Navigation**: Everything where you expect it
- **Responsive Design**: Beautiful on any screen size
- **Accessibility First**: Screen reader support and semantic widgets
- **Performance Optimized**: Smooth animations and efficient rendering

## 📱 Platform Support

QuietTube is designed to work across multiple platforms:

- **Android**: Full feature support with background playback
- **iOS**: Native iOS experience with system integration
- **Desktop**: Windows, macOS, and Linux support
- **Web**: Progressive Web App capabilities

## 🔧 Configuration

### Build Configuration
The app uses standard Flutter build configuration. Key settings:

- **Minimum SDK**: Android API 21, iOS 12.0
- **Target SDK**: Latest stable versions
- **Permissions**: Internet, wake lock, file access

### Customization
- **Colors**: Modify `lib/theme/app_theme.dart` for custom color schemes
- **Fonts**: Update theme configuration for different typography
- **Layout**: Adjust component layouts in `lib/widgets/`

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow Flutter/Dart coding standards
4. **Test thoroughly**: Ensure all features work on target platforms
5. **Submit a pull request**: Describe your changes

### Development Guidelines
- Use proper Dart/Flutter conventions
- Follow the existing project structure
- Add proper error handling
- Test on multiple platforms
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **YouTube**: For providing the content platform
- **Flutter Team**: For the amazing cross-platform framework
- **youtube_player_flutter**: For seamless YouTube integration
- **Provider**: For elegant state management
- **Material Design**: For beautiful, accessible UI components

## 🐛 Bug Reports & Feature Requests

Found a bug or have an idea? We'd love to hear from you!

- **Bug Reports**: [Create an issue](https://github.com/yourusername/quiettube-flutter/issues)
- **Feature Requests**: [Start a discussion](https://github.com/yourusername/quiettube-flutter/discussions)
- **Security Issues**: Email us at security@quiettube.app

---

**Made with ❤️ and Flutter for music lovers everywhere**

*QuietTube - Where music meets minimalism*