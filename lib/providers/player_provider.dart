import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:audio_session/audio_session.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/youtube_service.dart';

class PlayerProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  String? _activePlaylistId;
  String? _playingPlaylistId;
  int? _currentTrackIndex;
  bool _isPlaying = false;
  double _volume = 0.8;
  bool _loop = false;
  bool _isShuffled = false;
  double _progress = 0.0;
  double _duration = 0.0;
  List<Song> _queue = [];
  List<int> _shuffleOrder = [];
  
  YoutubePlayerController? _youtubeController; // Deprecated path
  ja.AudioPlayer? _audioPlayer;
  
  // Getters
  List<Playlist> get playlists => _playlists;
  String? get activePlaylistId => _activePlaylistId;
  String? get playingPlaylistId => _playingPlaylistId;
  int? get currentTrackIndex => _currentTrackIndex;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get loop => _loop;
  bool get isShuffled => _isShuffled;
  double get progress => _progress;
  double get duration => _duration;
  List<Song> get queue => _queue;
  YoutubePlayerController? get youtubeController => _youtubeController;
  ja.AudioPlayer? get audioPlayer => _audioPlayer;
  
  Playlist? get activePlaylist => 
      _playlists.where((p) => p.id == _activePlaylistId).firstOrNull;
  
  Playlist? get playingPlaylist => 
      _playlists.where((p) => p.id == _playingPlaylistId).firstOrNull;
  
  Song? get currentTrack {
    if (_queue.isNotEmpty) return _queue.first;
    if (playingPlaylist != null && _currentTrackIndex != null) {
      return playingPlaylist!.songs[_currentTrackIndex!];
    }
    return null;
  }

  PlayerProvider() {
    _loadPlaylists();
    _configureAudioSession();
  }

  void _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: false,
    ));
  }

  void _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getString('quietTubePlaylists');
    
    if (playlistsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(playlistsJson);
        _playlists = decoded.map((json) => Playlist.fromJson(json)).toList();
        
        if (_playlists.isNotEmpty && _activePlaylistId == null) {
          _activePlaylistId = _playlists.first.id;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading playlists: $e');
      }
    }
  }

  void _savePlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = json.encode(_playlists.map((p) => p.toJson()).toList());
    await prefs.setString('quietTubePlaylists', playlistsJson);
  }

  void selectPlaylist(String? playlistId) {
    _activePlaylistId = playlistId;
    notifyListeners();
  }

  void createPlaylist(String name) {
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: [],
    );
    
    _playlists.add(newPlaylist);
    if (_activePlaylistId == null) {
      _activePlaylistId = newPlaylist.id;
    }
    
    _savePlaylists();
    notifyListeners();
  }

  void deletePlaylist(String playlistId) {
    if (_playingPlaylistId == playlistId) {
      _isPlaying = false;
      _playingPlaylistId = null;
      _currentTrackIndex = null;
      _youtubeController?.pause();
    }
    
    _playlists.removeWhere((p) => p.id == playlistId);
    
    if (_activePlaylistId == playlistId) {
      _activePlaylistId = _playlists.isNotEmpty ? _playlists.first.id : null;
    }
    
    _savePlaylists();
    notifyListeners();
  }

  void updatePlaylistName(String playlistId, String newName) {
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      _playlists[playlistIndex] = _playlists[playlistIndex].copyWith(name: newName);
      _savePlaylists();
      notifyListeners();
    }
  }

  Song? addSongToPlaylist(String playlistId, String title, String url) {
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      final newSong = Song(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        url: url,
      );
      
      final updatedSongs = List<Song>.from(_playlists[playlistIndex].songs)..add(newSong);
      _playlists[playlistIndex] = _playlists[playlistIndex].copyWith(songs: updatedSongs);
      
      _savePlaylists();
      notifyListeners();
      return newSong;
    }
    return null;
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      final playlist = _playlists[playlistIndex];
      final songIndex = playlist.songs.indexWhere((s) => s.id == songId);
      
      if (songIndex != -1) {
        final isCurrentTrack = _playingPlaylistId == playlistId && _currentTrackIndex == songIndex;
        
        final updatedSongs = List<Song>.from(playlist.songs)..removeAt(songIndex);
        _playlists[playlistIndex] = playlist.copyWith(songs: updatedSongs);
        
        if (isCurrentTrack) {
          _isPlaying = false;
          _currentTrackIndex = null;
          _playingPlaylistId = null;
          _youtubeController?.pause();
        } else if (_playingPlaylistId == playlistId && _currentTrackIndex != null && songIndex < _currentTrackIndex!) {
          _currentTrackIndex = _currentTrackIndex! - 1;
        }
        
        _savePlaylists();
        notifyListeners();
      }
    }
  }

  void playTrack(String playlistId, int trackIndex) async {
    final playlist = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null || trackIndex >= playlist.songs.length) return;

    final song = playlist.songs[trackIndex];
    final videoId = YoutubePlayer.convertUrlToId(song.url);
    
    if (videoId == null) return;

    _queue.clear();
    _playingPlaylistId = playlistId;
    _activePlaylistId = playlistId;
    _currentTrackIndex = trackIndex;
    _progress = 0.0;
    _duration = 0.0;

    // Enable wakelock to prevent screen from turning off
    await WakelockPlus.enable();

    // Prefer native audio playback for background
    final audioUrl = await YouTubeService.getBestAudioStreamUrl(song.url);
    if (audioUrl != null) {
      // Dispose previous
      await _audioPlayer?.dispose();
      _audioPlayer = ja.AudioPlayer();

      // Listen to state
      _audioPlayer!.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        if (state.processingState == ja.ProcessingState.completed) {
          _onTrackEnded();
        }
        notifyListeners();
      });

      // Listen to position and duration updates for seek bar
      _audioPlayer!.positionStream.listen((position) {
        _progress = position.inSeconds.toDouble();
        notifyListeners();
      });
      _audioPlayer!.durationStream.listen((duration) {
        _duration = (duration?.inSeconds ?? 0).toDouble();
        notifyListeners();
      });

      await _audioPlayer!.setUrl(audioUrl);
      _duration = (_audioPlayer!.duration?.inSeconds ?? 0).toDouble();
      await _audioPlayer!.play();
      _isPlaying = true;
      notifyListeners();
      return;
    }

    // Fallback to WebView YouTube player if audio URL fails
    _youtubeController?.dispose();
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        hideControls: true,
        controlsVisibleAtStart: false,
        useHybridComposition: true,
      ),
    );
    _youtubeController!.addListener(_onPlayerStateChange);
    _isPlaying = true;
    notifyListeners();
  }

  void _onPlayerStateChange() {
    if (_youtubeController != null) {
      final playerState = _youtubeController!.value.playerState;
      final position = _youtubeController!.value.position;
      final duration = _youtubeController!.value.metaData.duration;

      _progress = position.inSeconds.toDouble();
      _duration = duration.inSeconds.toDouble();

      switch (playerState) {
        case PlayerState.playing:
          _isPlaying = true;
          break;
        case PlayerState.paused:
          _isPlaying = false;
          break;
        case PlayerState.ended:
          _onTrackEnded();
          break;
        default:
          break;
      }
      notifyListeners();
    }
  }

  void _onTrackEnded() {
    if (!_loop) {
      playNext();
    }
  }

  void togglePlay() async {
    if (_audioPlayer != null) {
      if (_audioPlayer!.playing) {
        await _audioPlayer!.pause();
        await WakelockPlus.disable();
      } else {
        await _audioPlayer!.play();
        await WakelockPlus.enable();
      }
      return;
    }
    if (_youtubeController != null) {
      if (_isPlaying) {
        _youtubeController!.pause();
        await WakelockPlus.disable();
      } else {
        _youtubeController!.play();
        await WakelockPlus.enable();
      }
    }
  }

  Future<void> playNext() async {
    // Play from queue first
    if (_queue.isNotEmpty) {
      _queue.removeAt(0);
      if (_queue.isNotEmpty) {
        final nextSong = _queue.first;
        final videoId = YoutubePlayer.convertUrlToId(nextSong.url);
        if (videoId != null) {
          if (_audioPlayer != null) {
            final nextAudio = await YouTubeService.getBestAudioStreamUrl(nextSong.url);
            if (nextAudio != null) {
              await _audioPlayer!.setUrl(nextAudio);
              await _audioPlayer!.play();
              _progress = 0.0;
              _duration = 0.0;
              _isPlaying = true;
              notifyListeners();
              return;
            }
          }
          _youtubeController?.load(videoId);
          _progress = 0.0;
          _duration = 0.0;
          _isPlaying = true;
          notifyListeners();
          return;
        }
      }
    }

    if (playingPlaylist == null || _currentTrackIndex == null) return;

    if (!_loop && !_isShuffled && _currentTrackIndex == playingPlaylist!.songs.length - 1) {
      _isPlaying = false;
      _youtubeController?.pause();
      notifyListeners();
      return;
    }

    int nextIndex;
    if (_isShuffled) {
      if (_shuffleOrder.isEmpty) _generateShuffleOrder(playingPlaylist!.songs.length);
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentTrackIndex!);
      if (!_loop && currentShuffleIndex == _shuffleOrder.length - 1) {
        _isPlaying = false;
        _youtubeController?.pause();
        notifyListeners();
        return;
      }
      final nextShuffleIndex = (currentShuffleIndex + 1) % _shuffleOrder.length;
      nextIndex = _shuffleOrder[nextShuffleIndex];
    } else {
      nextIndex = (_currentTrackIndex! + 1) % playingPlaylist!.songs.length;
    }

    final nextSong = playingPlaylist!.songs[nextIndex];
    final videoId = YoutubePlayer.convertUrlToId(nextSong.url);
    
    if (videoId != null) {
      _currentTrackIndex = nextIndex;
      if (_audioPlayer != null) {
        final nextAudio = await YouTubeService.getBestAudioStreamUrl(nextSong.url);
        if (nextAudio != null) {
          await _audioPlayer!.setUrl(nextAudio);
          await _audioPlayer!.play();
          _progress = 0.0;
          _duration = 0.0;
          _isPlaying = true;
          notifyListeners();
          return;
        }
      }
      _youtubeController?.load(videoId);
      _progress = 0.0;
      _duration = 0.0;
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> playPrevious() async {
    if (_queue.isNotEmpty) return;
    if (playingPlaylist == null || _currentTrackIndex == null) return;

    int prevIndex;
    if (_isShuffled) {
      if (_shuffleOrder.isEmpty) _generateShuffleOrder(playingPlaylist!.songs.length);
      final currentShuffleIndex = _shuffleOrder.indexOf(_currentTrackIndex!);
      final prevShuffleIndex = (currentShuffleIndex - 1 + _shuffleOrder.length) % _shuffleOrder.length;
      prevIndex = _shuffleOrder[prevShuffleIndex];
    } else {
      prevIndex = (_currentTrackIndex! - 1 + playingPlaylist!.songs.length) % playingPlaylist!.songs.length;
    }

    final prevSong = playingPlaylist!.songs[prevIndex];
    final videoId = YoutubePlayer.convertUrlToId(prevSong.url);
    
    if (videoId != null) {
      _currentTrackIndex = prevIndex;
      if (_audioPlayer != null) {
        final prevAudio = await YouTubeService.getBestAudioStreamUrl(prevSong.url);
        if (prevAudio != null) {
          await _audioPlayer!.setUrl(prevAudio);
          await _audioPlayer!.play();
          _progress = 0.0;
          _duration = 0.0;
          _isPlaying = true;
          notifyListeners();
          return;
        }
      }
      _youtubeController?.load(videoId);
      _progress = 0.0;
      _duration = 0.0;
      _isPlaying = true;
      notifyListeners();
    }
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _youtubeController?.setVolume((volume * 100).round());
    notifyListeners();
  }

  void toggleLoop() {
    _loop = !_loop;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled && playingPlaylist != null) {
      _generateShuffleOrder(playingPlaylist!.songs.length);
    } else {
      _shuffleOrder.clear();
    }
    notifyListeners();
  }

  void _generateShuffleOrder(int songCount) {
    _shuffleOrder = List.generate(songCount, (index) => index);
    _shuffleOrder.shuffle(Random());
  }

  Future<void> seek(double seconds) async {
    if (_audioPlayer != null) {
      await _audioPlayer!.seek(Duration(seconds: seconds.round()));
    } else {
      _youtubeController?.seekTo(Duration(seconds: seconds.round()));
    }
    _progress = seconds;
    notifyListeners();
  }

  void queueNext(Song song) {
    _queue.add(song);
    if (!_isPlaying && currentTrack == null) {
      final videoId = YoutubePlayer.convertUrlToId(song.url);
      if (videoId != null) {
        _youtubeController?.load(videoId);
        _isPlaying = true;
      }
    }
    notifyListeners();
  }

  String exportPlaylists([String? playlistId]) {
    if (playlistId != null) {
      final playlist = _playlists.where((p) => p.id == playlistId).firstOrNull;
      return playlist != null ? json.encode(playlist.toJson()) : '';
    } else {
      return json.encode(_playlists.map((p) => p.toJson()).toList());
    }
  }

  void importPlaylists(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      List<Playlist> importedPlaylists = [];
      
      if (decoded is List) {
        importedPlaylists = decoded.map((json) => Playlist.fromJson(json)).toList();
      } else {
        importedPlaylists = [Playlist.fromJson(decoded)];
      }
      
      final existingIds = _playlists.map((p) => p.id).toSet();
      final newPlaylists = importedPlaylists.where((p) => !existingIds.contains(p.id)).toList();
      
      _playlists.addAll(newPlaylists);
      
      if (_activePlaylistId == null && newPlaylists.isNotEmpty) {
        _activePlaylistId = newPlaylists.first.id;
      }
      
      _savePlaylists();
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing playlists: $e');
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _audioPlayer?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
}