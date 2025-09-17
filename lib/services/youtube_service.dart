import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as ytx;

class YouTubeService {
  static final ytx.YoutubeExplode _yt = ytx.YoutubeExplode();
  static Future<String> getVideoTitle(String url) async {
    try {
      final oembedUrl = 'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json';
      final response = await http.get(Uri.parse(oembedUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['title'] ?? 'YouTube Video';
      }
    } catch (e) {
      print('Error fetching YouTube video title: $e');
    }
    
    return 'YouTube Video';
  }

  static String? getThumbnailUrl(String url, {String quality = 'mqdefault'}) {
    final videoId = _extractVideoId(url);
    if (videoId == null) return null;
    
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  static Future<String?> getBestAudioStreamUrl(String url) async {
    try {
      final videoId = _extractVideoId(url);
      if (videoId == null) return null;
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audio = manifest.audioOnly.withHighestBitrate();
      return audio.url.toString();
    } catch (e) {
      print('Error fetching audio stream: $e');
      return null;
    }
  }

  static String? _extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.first;
      } else if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
    } catch (e) {
      print('Error extracting video ID: $e');
    }
    return null;
  }
}