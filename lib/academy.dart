// ignore_for_file: camel_case_types, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:kdrive/models/academy_model.dart';
import 'package:kdrive/utils/distance_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';

class Academy extends StatefulWidget {
  const Academy({
    super.key,
    required this.response,
    required this.suggestionResponse,
  });

  final List<AcademyModel> response;
  final List<AcademyModel> suggestionResponse;

  @override
  State<Academy> createState() => _AcademyState();
}

class _AcademyState extends State<Academy> {
  List<MapEntry<AcademyModel, double>>? _sortedAcademiesWithDistance;
  List<MapEntry<AcademyModel, double>>? _sortedSuggestionAcademiesWithDistance;
  bool _isLoading = true;

  // 상수 정의
  static const double _cardHeight = 100.0;
  static const double _imageWidth = 100.0;
  static const double _imageHeight = 70.0;
  static const double _suggestionContainerHeight = 108.0;
  static const double _borderRadius = 8.0;
  static const double _spacing = 12.0;

  @override
  void initState() {
    super.initState();
    _loadAcademies();
  }

  Future<void> _loadAcademies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 위치를 한 번만 가져오기
      final currentPosition = await DistanceService.getCurrentPosition();

      // 일반 학원과 추천 학원을 병렬로 처리
      final results = await Future.wait([
        _calculateDistances(widget.response, currentPosition),
        _calculateDistances(widget.suggestionResponse, currentPosition),
      ]);

      setState(() {
        _sortedAcademiesWithDistance = results[0];
        _sortedSuggestionAcademiesWithDistance = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학원 정보를 불러오는 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  // 거리 계산을 통합한 메서드
  Future<List<MapEntry<AcademyModel, double>>> _calculateDistances(
    List<AcademyModel> academies,
    Position? currentPosition,
  ) async {
    if (currentPosition == null) {
      return academies.map((academy) => MapEntry(academy, 0.0)).toList();
    }

    // 모든 학원의 거리를 병렬로 계산
    final distanceFutures = academies.map((academy) async {
      final distance = await DistanceService.calculateDistanceFromPosition(
        currentPosition,
        academy.latitude,
        academy.longitude,
      );
      return MapEntry(academy, distance);
    });

    final academiesWithDistance = await Future.wait(distanceFutures);
    academiesWithDistance.sort((a, b) => a.value.compareTo(b.value));

    return academiesWithDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('운전전문학원'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildShimmerLoading()
          : Column(
              children: [
                // 추천 학원 섹션
                Container(
                  color: Colors.amber[500],
                  height: _suggestionContainerHeight,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        _sortedSuggestionAcademiesWithDistance?.length ?? 0,
                    itemBuilder: (context, index) {
                      final entry =
                          _sortedSuggestionAcademiesWithDistance![index];
                      return AcademyCard(
                        academy: entry.key,
                        distance: entry.value,
                        onTap: () => _showAcademyPopup(entry.key),
                      );
                    },
                  ),
                ),
                // 일반 학원 섹션
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _sortedAcademiesWithDistance?.length ?? 0,
                    itemBuilder: (context, index) {
                      final entry = _sortedAcademiesWithDistance![index];
                      return AcademyCard(
                        academy: entry.key,
                        distance: entry.value,
                        onTap: () => _showAcademyPopup(entry.key),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // 추천 학원 섹션 shimmer
        Container(
          color: Colors.amber[500],
          height: _suggestionContainerHeight,
          child: Shimmer.fromColors(
            baseColor: Colors.amber[400]!,
            highlightColor: Colors.amber[200]!,
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => _buildShimmerCard(),
            ),
          ),
        ),
        // 일반 학원 섹션 shimmer
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                // 로딩 메시지
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '학원 정보를 불러오는 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                // shimmer 카드들
                Expanded(
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) => _buildShimmerCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Card.outlined(
      child: SizedBox(
        width: double.infinity,
        height: _cardHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 이미지 shimmer
              Container(
                width: _imageWidth,
                height: _imageHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
              ),
              const SizedBox(width: _spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 제목 shimmer
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 전화번호 shimmer
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 주소 shimmer
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 거리 shimmer
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 팝업 표시 메서드
  Future<void> _showAcademyPopup(AcademyModel academy) async {
    try {
      final distance = await DistanceService.calculateDistance(
        academy.latitude,
        academy.longitude,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AcademyPopupDialog(
          academy: academy,
          distance: distance,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('팝업을 표시하는 중 오류가 발생했습니다.')),
        );
      }
    }
  }
}

class AcademyCard extends StatelessWidget {
  const AcademyCard({
    super.key,
    required this.academy,
    this.distance,
    required this.onTap,
  });

  final AcademyModel academy;
  final double? distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: academy.image.toString(),
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 70,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        academy.name.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        academy.phone.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        academy.address.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (distance != null)
                        Text(
                          '${distance!.toStringAsFixed(1)}km',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AcademyPopupDialog extends StatelessWidget {
  const AcademyPopupDialog({
    super.key,
    required this.academy,
    required this.distance,
  });

  final AcademyModel academy;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단 이미지 섹션
            _buildImageSection(context),
            // 콘텐츠 섹션
            Expanded(
              child: _buildContentSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // 이미지
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: CachedNetworkImage(
              imageUrl: academy.image.toString(),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber[400]!,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.grey,
                  size: 48,
                ),
              ),
            ),
          ),
          // 그라데이션 오버레이
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.3),
                ],
              ),
            ),
          ),
          // 거리 정보 배지
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distance > 0
                        ? '${distance.toStringAsFixed(1)}km'
                        : '거리 계산 실패',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 닫기 버튼
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 학원 이름
          Text(
            academy.name.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // 종별 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Text(
              academy.type.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 주소 정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  academy.address.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 홈페이지 버튼
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.grey[50],
              ),
              onPressed: () => _launchUrl(academy.homepage.toString(), '홈페이지'),
              icon: const Icon(Icons.language, size: 16),
              label: const Text(
                '홈페이지',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 액션 버튼들
          Row(
            children: [
              // 전화 버튼
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _launchUrl('tel://${academy.phone}', '전화'),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text(
                      '전화하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 길찾기 버튼
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _launchUrl(academy.naver.toString(), '지도'),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text(
                      '길찾기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 닫기 버튼
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.grey[50],
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 16),
                label: const Text(
                  '닫기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url, String action) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      // 에러 처리는 상위에서 처리됨
    }
  }
}
