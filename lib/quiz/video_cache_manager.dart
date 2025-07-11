import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, DateTime> _lastAccess = {};
  final Map<String, int> _accessCount = {};
  final Map<String, DateTime> _loadTimes = {};

  int _totalRequests = 0;
  int _cacheHits = 0;
  final List<Duration> _loadDurations = [];

  /// 비디오 컨트롤러 가져오기 (캐시 우선)
  Future<VideoPlayerController> getController(String url) async {
    _totalRequests++;

    if (_controllers.containsKey(url)) {
      _cacheHits++;
      _lastAccess[url] = DateTime.now();
      _accessCount[url] = (_accessCount[url] ?? 0) + 1;
      return _controllers[url]!;
    }

    final stopwatch = Stopwatch()..start();

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();

      _controllers[url] = controller;
      _lastAccess[url] = DateTime.now();
      _accessCount[url] = 1;
      _loadTimes[url] = DateTime.now();

      stopwatch.stop();
      _loadDurations.add(stopwatch.elapsed);

      if (kDebugMode) {
        print('비디오 로드 완료: $url (${stopwatch.elapsed.inMilliseconds}ms)');
      }

      return controller;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('비디오 로드 실패: $url - $e');
      }
      rethrow;
    }
  }

  /// 비디오들 프리로딩
  Future<void> preloadVideos(List<String> urls) async {
    for (final url in urls) {
      if (!_controllers.containsKey(url)) {
        try {
          unawaited(getController(url));
        } catch (e) {
          if (kDebugMode) {
            print('프리로딩 실패: $url - $e');
          }
        }
      }
    }
  }

  /// 메모리 최적화
  void optimizeMemory() {
    if (_controllers.length <= 10) return; // 최소 10개는 유지

    final now = DateTime.now();
    final urlsToRemove = <String>[];

    // 가장 오래된 비디오들 제거 (LRU 방식)
    final sortedUrls = _lastAccess.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final removeCount =
        (_controllers.length - 10).clamp(0, 5); // 한 번에 최대 5개만 제거

    for (int i = 0; i < removeCount && i < sortedUrls.length; i++) {
      final url = sortedUrls[i].key;
      final lastAccess = sortedUrls[i].value;

      // 10분 이상 사용되지 않은 비디오만 제거
      if (now.difference(lastAccess).inMinutes > 10) {
        urlsToRemove.add(url);
      }
    }

    for (final url in urlsToRemove) {
      _removeController(url);
    }

    if (kDebugMode && urlsToRemove.isNotEmpty) {
      print('메모리 최적화: ${urlsToRemove.length}개 비디오 제거');
    }
  }

  /// 컨트롤러 제거
  void _removeController(String url) {
    final controller = _controllers.remove(url);
    _lastAccess.remove(url);
    _accessCount.remove(url);
    _loadTimes.remove(url);

    controller?.dispose();
  }

  /// 성능 통계 반환
  Map<String, dynamic> getPerformanceStats() {
    final cacheHitRate =
        _totalRequests > 0 ? (_cacheHits / _totalRequests) * 100 : 0.0;

    final averageLoadTime = _loadDurations.isNotEmpty
        ? _loadDurations.reduce((a, b) => a + b) ~/ _loadDurations.length
        : Duration.zero;

    final cacheEfficiency = _controllers.isNotEmpty
        ? _accessCount.values.reduce((a, b) => a + b) / _controllers.length
        : 0.0;

    return {
      'cacheHitRate': cacheHitRate,
      'averageLoadTime': averageLoadTime,
      'cacheEfficiency': cacheEfficiency,
      'totalCached': _controllers.length,
      'totalRequests': _totalRequests,
      'cacheHits': _cacheHits,
    };
  }

  /// 캐시 정보 반환
  Map<String, dynamic> getCacheInfo() {
    return {
      'cachedUrls': _controllers.keys.toList(),
      'lastAccess': Map<String, DateTime>.from(_lastAccess),
      'accessCount': Map<String, int>.from(_accessCount),
      'loadTimes': Map<String, DateTime>.from(_loadTimes),
    };
  }

  /// 모든 캐시 정리
  void clearCache() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _lastAccess.clear();
    _accessCount.clear();
    _loadTimes.clear();
    _loadDurations.clear();
    _totalRequests = 0;
    _cacheHits = 0;
  }
}
