import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
// import 'video_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

/// Stateful widget to fetch and then display video content.
class MP4Player extends StatefulWidget {
  const MP4Player({super.key, required this.url});

  final String url;

  @override
  MP4PlayerState createState() => MP4PlayerState();
}

class MP4PlayerState extends State<MP4Player> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _timeoutTimer;
  static const Duration _timeoutDuration = Duration(seconds: 8); // 타임아웃 단축
  // final VideoCacheManager _cacheManager = VideoCacheManager();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // 기존 컨트롤러 정리
      await _disposeController();

      // 타임아웃 설정
      _timeoutTimer = Timer(_timeoutDuration, () {
        if (!_isInitialized && mounted) {
          _handleError('비디오 로딩 시간이 초과되었습니다.');
        }
      });

      // 실제 비디오 컨트롤러 생성 및 초기화
      _controller = VideoPlayerController.network(widget.url);
      await _controller!.initialize();

      _timeoutTimer?.cancel();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      _handleError('비디오 로딩 중 오류가 발생했습니다: $e');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
        _isLoading = false;
      });
    }
    debugPrint('비디오 오류: $message');
  }

  Future<void> _disposeController() async {
    if (_controller != null) {
      await _controller!.pause();
      // 캐시 매니저가 관리하므로 dispose는 하지 않음
      _controller = null;
    }
  }

  Future<void> _retryLoading() async {
    await _initializeController();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading || !_isInitialized) {
      return _buildLoadingWidget();
    }

    return _buildVideoWidget();
  }

  Widget _buildLoadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        width: double.infinity,
        height: 200,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoWidget() {
    if (_controller == null) return _buildErrorWidget();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          // 재생/일시정지 버튼
          if (!_controller!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _controller!.play();
                  });
                },
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _disposeController();
    super.dispose();
  }
}
