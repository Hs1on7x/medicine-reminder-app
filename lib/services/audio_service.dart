import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _notificationPlayer = AudioPlayer();
  bool _isPlaying = false;
  
  // Singleton pattern
  factory AudioService() {
    return _instance;
  }
  
  AudioService._internal();
  
  Future<void> initialize() async {
    // Set up audio player
    await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the music
    await _notificationPlayer.setReleaseMode(ReleaseMode.release); // Play once
    debugPrint('AudioService initialized');
  }
  
  Future<void> playBackgroundMusic() async {
    if (!_isPlaying) {
      try {
        // In a real app, you would use an actual music file
        // For now, we'll use a placeholder URL that won't actually play
        await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
        _isPlaying = true;
        debugPrint('Background music started');
      } catch (e) {
        debugPrint('Error playing background music: $e');
      }
    }
  }
  
  Future<void> pauseBackgroundMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
      debugPrint('Background music paused');
    }
  }
  
  Future<void> resumeBackgroundMusic() async {
    if (!_isPlaying) {
      await _audioPlayer.resume();
      _isPlaying = true;
      debugPrint('Background music resumed');
    }
  }
  
  Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    debugPrint('Background music stopped');
  }
  
  Future<void> playNotificationSound() async {
    try {
      await _notificationPlayer.play(AssetSource('audio/loud_alarm.mp3'));
      debugPrint('Notification sound played: loud_alarm.mp3');
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
      // Try a simpler approach if the first attempt fails
      try {
        await _notificationPlayer.play(AssetSource('audio/loud_alarm.mp3'), mode: PlayerMode.lowLatency);
        debugPrint('Notification sound played with low latency mode');
      } catch (e) {
        debugPrint('Failed to play notification sound: $e');
      }
    }
  }
  
  Future<void> playSound(String assetPath) async {
    try {
      // Extract just the filename from the path
      final fileName = assetPath.split('/').last;
      await _notificationPlayer.play(AssetSource(fileName));
      debugPrint('Sound played: $assetPath');
    } catch (e) {
      debugPrint('Error playing sound: $e');
      // Try a simpler approach if the first attempt fails
      try {
        final fileName = assetPath.split('/').last;
        await _notificationPlayer.play(AssetSource(fileName), mode: PlayerMode.lowLatency);
        debugPrint('Sound played with low latency mode: $assetPath');
      } catch (e) {
        debugPrint('Failed to play sound: $e');
      }
    }
  }
  
  Future<void> stopSound() async {
    try {
      await _notificationPlayer.stop();
      debugPrint('Notification sound stopped');
    } catch (e) {
      debugPrint('Error stopping notification sound: $e');
    }
  }
  
  bool get isPlaying => _isPlaying;
  
  void dispose() {
    _audioPlayer.dispose();
    _notificationPlayer.dispose();
    debugPrint('AudioService disposed');
  }
} 