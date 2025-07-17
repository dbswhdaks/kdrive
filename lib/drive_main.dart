// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, prefer_const_constructors_in_immutables, unused_field, use_build_context_synchronously, deprecated_member_use, avoid_print, unused_import
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kdrive/academy.dart';
import 'package:kdrive/main_quiz_nanum.dart';
import 'package:kdrive/models/hospital_model.dart';
import 'package:kdrive/quiz_nanum.dart';
import 'package:kdrive/test_center.dart';
import 'package:kdrive/test_center/drive_list6.dart';
import 'package:kdrive/test_center/exam_information.dart';
import 'package:kdrive/test_center/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import 'hospital.dart';

late Position position;

// ======= 심플 스타일 컬러/폰트 상수 =======
const kMainColor = Color(0xFF2563EB); // 메인 블루
const kBgColor = Color(0xFFF5F6FA); // 밝은 그레이
const kTextColor = Color(0xFF1A202C); // 진한 블랙
const kSubTextColor = Color(0xFF718096); // 서브 텍스트
const kCardRadius = 16.0;
const kSectionPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 8);

// 3D 효과 보조 버튼 위젯
class _ThreeDSecondaryButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ThreeDSecondaryButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_ThreeDSecondaryButton> createState() => _ThreeDSecondaryButtonState();
}

class _ThreeDSecondaryButtonState extends State<_ThreeDSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 90),
        curve: Curves.easeInOut,
        transform: _isPressed
            ? Matrix4.translationValues(0, 4, 0)
            : Matrix4.identity(),
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBgColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.04 : 0.08),
              blurRadius: _isPressed ? 2 : 6,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(widget.icon, size: 24, color: widget.iconColor),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kTextColor)),
                    SizedBox(height: 2),
                    Text(widget.subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: kSubTextColor,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: kSubTextColor),
            ],
          ),
        ),
      ),
    );
  }
}

class Drive_Main extends StatefulWidget {
  /// 드라이브 메인 화면
  Drive_Main({super.key});

  @override
  State<Drive_Main> createState() => _Drive_MainState();
}

class _Drive_MainState extends State<Drive_Main> {
  /// 드라이브 메인 화면 상태
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 드라이브 메인 화면 스케폴드
      backgroundColor: kBgColor,
      appBar: AppBar(
        /// 드라이브 메인 화면 앱바
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          /// 드라이브 메인 화면 앱바 아이콘
          color: kTextColor,
          size: 28, //햄버거 아이콘 크기
        ),
        // title: Text(
        //   /// 드라이브 메인 화면 앱바 타이틀
        //   '2025 최신판 문제은행',
        //   style: TextStyle(
        //     /// 드라이브 메인 화면 앱바 타이틀
        //     color: Colors.grey[800],
        //     fontSize: 16,
        //     fontWeight: FontWeight.w600,
        //     letterSpacing: -0.5,
        //   ),
        // ),
      ),
      drawer: Drawer(
        /// 드라이브 메인 화면 드로워
        child: Container(
          /// 드라이브 메인 화면 드로워 컨테이너
          color: Colors.white,
          child: Column(
            /// 드라이브 메인 화면 드로워 컨테이너 내부 컬럼
            children: [
              // 상단 앱명/로고
              Container(
                color: Colors.green[50],
                width: double.infinity,
                padding: EdgeInsets.only(top: 70, bottom: 12),
                alignment: Alignment.center,
                child: Text(
                  '전체보기',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
              // Divider(height: 1, thickness: 1, color: kBgColor),
              Expanded(
                /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildSectionHeader('학습 및 문제풀이',
                        icon: Icons.menu_book_outlined),

                    /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 섹션 헤더
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '운전면허 문제은행',
                      subtitle: '예습 하기',
                      icon: Icons.school,
                      iconColor: kMainColor,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizNanum()));
                      },
                    ),

                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '문제풀이(모의고사)',
                      subtitle: '테스트 하기',
                      icon: Icons.quiz_rounded,
                      iconColor: Color(0xFF0891B2),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainQuizNanum()));
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSectionHeader('위치 기반 서비스', icon: Icons.map),
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '운전전문학원 찾기',
                      subtitle: 'academy',
                      icon: Icons.location_on_outlined,
                      iconColor: Color(0xFFEA580C),
                      onTap: () async {
                        var permissionStatus = await Permission.location.status;
                        print(permissionStatus);
                        if (permissionStatus.isDenied ||
                            permissionStatus.isPermanentlyDenied) {
                          var requested = await Permission.location.request();
                          if (!requested.isGranted) {
                            return;
                          }
                        }

                        var response = await getAcademyList();
                        var suggestionResponse =
                            await getAcademySuggestionList();

                        Get.to(Academy(
                            response: response,
                            suggestionResponse: suggestionResponse));
                      },
                    ),
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '운전면허 시험장 찾기',
                      subtitle: 'test_center',
                      icon: Icons.location_on_outlined,
                      iconColor: Color(0xFF7C3AED),
                      onTap: () async {
                        var permissionStatus = await Permission.location.status;
                        print(permissionStatus);
                        if (permissionStatus.isDenied ||
                            permissionStatus.isPermanentlyDenied) {
                          var requested = await Permission.location.request();
                          if (!requested.isGranted) {
                            return;
                          }
                        }
                        var response = await getLicenseList();

                        Get.to(Test_Center(response: response));
                      },
                    ),
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '신체검사 지정병원',
                      subtitle: 'hospital',
                      icon: Icons.local_hospital,
                      iconColor: Color(0xFFDC2626),
                      onTap: () async {
                        try {
                          if (!await _checkLocationPermission()) {
                            _showErrorDialog(
                                '위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.');
                            return;
                          }
                          _showShimmerDialog();
                          final hospitalList = await _getSortedHospitalList();
                          _hideDialog();
                          Get.to(() => Hospital(hospitalList: hospitalList));
                        } on PermissionDeniedException {
                          _hideDialog();
                          _showErrorDialog(
                              '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.');
                        } on LocationServiceDisabledException {
                          _hideDialog();
                          _showErrorDialog(
                              '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
                        } catch (e) {
                          _hideDialog();
                          _showErrorDialog(
                              '병원 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSectionHeader('정보 및 안내', icon: Icons.info),
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '운전면허 시험안내',
                      subtitle: '시험 정보',
                      icon: Icons.info,
                      iconColor: Color(0xFFD97706),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExamInformation()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// 드라이브 메인 화면 바디
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
            padding: kSectionPadding,
            child: Column(
              /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컬럼
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 섹션
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('2025 최신판 문제은행',
                      //     style: TextStyle(
                      //         fontSize: 14,
                      //         color: Colors.blue[900],
                      //         fontWeight: FontWeight.w500)),
                      // SizedBox(height: 2),
                      Text('운전면허 필기시험 문제풀이!',
                          style: TextStyle(
                              fontSize: 18,
                              color: kSubTextColor,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 메인 버튼 그리드
                Row(
                  children: [
                    Expanded(
                      child: _buildMainButton(
                        title: '문제풀이',
                        subtitle: '모의고사',
                        icon: Icons.quiz,
                        color: Color(0xFFDBEAFE), // 연하늘
                        iconColor: Color(0xFF2563EB), // 진한 파랑
                        onTap: () async {
                          await context.setLocale(Locale("ko"));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainQuizNanum()));
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildMainButton(
                        title: '운전전문학원',
                        subtitle: '찾기',
                        icon: Icons.school,
                        color: Color(0xFFFFF7AE), // 연오렌지
                        iconColor: Color(0xFFEA580C), // 진한 오렌지
                        onTap: () async {
                          var permissionStatus =
                              await Permission.location.status;
                          print(permissionStatus);
                          if (permissionStatus.isDenied ||
                              permissionStatus.isPermanentlyDenied) {
                            var requested = await Permission.location.request();
                            if (!requested.isGranted) {
                              return;
                            }
                          }

                          var response = await getAcademyList();
                          print("response: ${response.length}");

                          var suggestionResponse =
                              await getAcademySuggestionList();

                          Get.to(Academy(

                              /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                              response: response,
                              suggestionResponse: suggestionResponse));
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMainButton(
                        title: '신체검사',
                        subtitle: '지정병원',
                        icon: Icons.local_hospital,
                        color: Color(0xFFFFE4E6), // 연핑크
                        iconColor: Color(0xFFDC2626), // 진한 레드
                        onTap: () async {
                          try {
                            if (!await _checkLocationPermission()) {
                              _showErrorDialog(
                                  '위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.');
                              return;
                            }
                            _showShimmerDialog();
                            final hospitalList = await _getSortedHospitalList();
                            _hideDialog();
                            Get.to(() => Hospital(hospitalList: hospitalList));
                          } on PermissionDeniedException {
                            _hideDialog();
                            _showErrorDialog(
                                '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.');
                          } on LocationServiceDisabledException {
                            _hideDialog();
                            _showErrorDialog(
                                '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
                          } catch (e) {
                            _hideDialog();
                            _showErrorDialog(
                                '병원 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildMainButton(
                        title: '면허시험장',
                        subtitle: '찾기',
                        icon: Icons.location_on,
                        color: Color(0xFFD1FAE5), // 연민트
                        iconColor: Color(0xFF16A34A), // 진한 그린
                        onTap: () async {
                          var permissionStatus =
                              await Permission.location.status;
                          print(permissionStatus);
                          if (permissionStatus.isDenied ||
                              permissionStatus.isPermanentlyDenied) {
                            var requested = await Permission.location.request();
                            if (!requested.isGranted) {
                              return;
                            }
                          }

                          var response = await getLicenseList();

                          Get.to(Test_Center(response: response));
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // 보조 버튼들
                _buildSecondaryButton(
                  /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                  title: '문제은행',
                  subtitle: '모두 보기 (1,2종보통,대형,특수,원동기)',
                  icon: Icons.book_outlined,
                  iconColor: kMainColor,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => QuizNanum()));
                  },
                ),
                SizedBox(height: 12),
                _buildSecondaryButton(
                  /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                  title: '운전면허 시험안내',
                  subtitle: '취득절차 및 시험안내',
                  icon: Icons.info_outline,
                  iconColor: Color(0xFFEA580C),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExamInformation()));
                  },
                ),
                SizedBox(height: 24),

                // 캐러셀 섹션
                CarouselSlider(

                    /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                    items: [
                      _buildCarouselItem(
                        /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                        title: '운전전문학원',
                        subtitle: '가까운 학원 찾기',
                        color: Color(0xFFFED7AA),
                        onTap: () async {
                          var permissionStatus =
                              await Permission.location.status;
                          print(permissionStatus);
                          if (permissionStatus.isDenied ||
                              permissionStatus.isPermanentlyDenied) {
                            var requested = await Permission.location.request();
                            if (!requested.isGranted) {
                              return;
                            }
                          }

                          var response = await getAcademyList();

                          var suggestionResponse =
                              await getAcademySuggestionList();

                          Get.to(Academy(
                              response: response,
                              suggestionResponse: suggestionResponse));
                        },
                      ),
                      _buildCarouselItem(
                        /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내
                        /// 신체검사 버튼
                        title: '신체검사',
                        subtitle: '지정병원 찾기',
                        color: Color(0xFFFECACA),
                        onTap: () async {
                          try {
                            if (!await _checkLocationPermission()) {
                              _showErrorDialog(
                                  '위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.');
                              return;
                            }
                            _showShimmerDialog();
                            final hospitalList = await _getSortedHospitalList();
                            _hideDialog();
                            Get.to(() => Hospital(hospitalList: hospitalList));
                          } on PermissionDeniedException {
                            _hideDialog();
                            _showErrorDialog(
                                '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.');
                          } on LocationServiceDisabledException {
                            _hideDialog();
                            _showErrorDialog(
                                '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
                          } catch (e) {
                            _hideDialog();
                            _showErrorDialog(
                                '병원 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
                          }
                        },
                      ),
                      _buildCarouselItem(
                        /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                        title: '면허시험장',
                        subtitle: '시험장 찾기',
                        color: Color(0xFFBBF7D0),
                        onTap: () async {
                          var permissionStatus =
                              await Permission.location.status;
                          print(permissionStatus);
                          if (permissionStatus.isDenied ||
                              permissionStatus.isPermanentlyDenied) {
                            var requested = await Permission.location.request();
                            if (!requested.isGranted) {
                              return;
                            }
                          }
                          var response = await getLicenseList();

                          Get.to(Test_Center(response: response));
                        },
                      ),
                      _buildCarouselItem(
                        /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                        title: '면허취소자',
                        subtitle: '음주운전 및 벌점',
                        color: Color(0xFFE9D5FF),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Drive_List6()));
                          print('3333');
                        },
                      ),
                      _buildCarouselItem(
                        /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                        title: '운전면허시험',
                        subtitle: '시험절차 및 안내',
                        color: Color(0xFFDBEAFE),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExamInformation()));
                        },
                      ),
                    ],
                    options: CarouselOptions(
                      height: 80,
                      viewportFraction: 0.35,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      enlargeFactor: 0.0,
                      scrollDirection: Axis.horizontal,
                    )),
              ],
            )),
      )),
    );
  }

  Widget _buildMainButton({
    /// 문제풀이 버튼, 운전학원 버튼
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      /// 문제풀이 버튼
      onTap: onTap,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(kCardRadius),
          border: Border.all(color: color.withOpacity(0.7), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                // 문제은행 버튼 내부 텍스트
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return _ThreeDSecondaryButton(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
    );
  }

  Widget _buildCarouselItem({
    /// 캐러셀 버튼
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      /// 캐러셀 버튼 컨테이너
      width: 120,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,

        /// 캐러셀 버튼 클릭 시 함수 실행
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 80,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBgColor, width: 1),
          ),
          child: Column(
            /// 캐러셀 버튼 컨테이너 내부 컬럼
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,

                  /// 캐러셀 버튼 타이틀
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 4),
              Text(subtitle,

                  /// 캐러셀 버튼 서브타이틀
                  style: TextStyle(
                      fontSize: 12,
                      color: kSubTextColor,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    /// 드로워 버튼
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      /// 드로워 버튼 컨테이너
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, size: 20, color: iconColor),

        /// 드로워 버튼 아이콘
        title: Text(title,
            style: TextStyle(
                color: kTextColor, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle,
            style: TextStyle(
                color: kSubTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        onTap: onTap,

        /// 드로워 버튼 클릭 시 함수 실행
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    /// 섹션 헤더
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      margin: EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        /// 섹션 헤더 컨테이너
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: kMainColor),
            SizedBox(width: 8),
          ],
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextColor)),
        ],
      ),
    );
  }

  Widget _buildShimmerLoadingDialog() {
    return Dialog(
      /// 로딩 인디케이터 컨테이너
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          /// 로딩 인디케이터 컨테이너 내부 컬럼
          mainAxisSize: MainAxisSize.min,
          children: [
            // 로딩 텍스트
            Text(
              '병원 정보를 불러오는 중...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),
            // Shimmer 효과가 적용된 로딩 인디케이터
            Shimmer.fromColors(
              /// 로딩 인디케이터 컨테이너
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                /// 로딩 인디케이터 컨테이너
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Shimmer 효과가 적용된 텍스트
            Shimmer.fromColors(
              /// 로딩 인디케이터 컨테이너
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                /// 로딩 인디케이터 컨테이너
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            SizedBox(height: 8),
            Shimmer.fromColors(
              /// 로딩 인디케이터 컨테이너
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                /// 로딩 인디케이터 컨테이너
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      /// 에러 다이얼로그
      AlertDialog(
        title: Text('알림'),
        content: Text(message),
        actions: [
          /// 에러 다이얼로그 액션
          TextButton(
            /// 에러 다이얼로그 액션 버튼
            onPressed: () => Get.back(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 위치 권한 체크 및 요청 함수
  Future<bool> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      var requested = await Permission.location.request();
      return requested.isGranted;
    }
    return status.isGranted;
  }

  /// 병원 리스트+거리 계산 및 정렬 함수
  Future<List<HospitalModel>> _getSortedHospitalList() async {
    final results = await Future.wait([
      getHospitalList(),
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
    ]);
    final hospitalList = results[0] as List<HospitalModel>;
    final currentPosition = results[1] as Position;
    for (final hospital in hospitalList) {
      hospital.distance = hospital.calculateDistance(currentPosition);
    }
    hospitalList.sort((a, b) {
      if (a.distance == null || b.distance == null) return 0;
      return a.distance!.compareTo(b.distance!);
    });
    return hospitalList;
  }

  /// shimmer 로딩 다이얼로그 표시
  void _showShimmerDialog() {
    Get.dialog(_buildShimmerLoadingDialog(), barrierDismissible: false);
  }

  /// 다이얼로그 닫기
  void _hideDialog() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
