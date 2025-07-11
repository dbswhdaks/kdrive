// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, prefer_const_constructors_in_immutables, unused_field, use_build_context_synchronously, deprecated_member_use, avoid_print
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
// import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import 'hospital.dart';

late Position position;

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
      appBar: AppBar(
        /// 드라이브 메인 화면 앱바
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          /// 드라이브 메인 화면 앱바 아이콘
          color: Color(0xFF2D3748),
          size: 28, //햄버거 아이콘 크기
        ),
        title: Text(
          /// 드라이브 메인 화면 앱바 타이틀
          '',
          style: TextStyle(
            /// 드라이브 메인 화면 앱바 타이틀
            color: Color(0xFF1A202C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: Drawer(
        /// 드라이브 메인 화면 드로워
        child: Container(
          /// 드라이브 메인 화면 드로워 컨테이너
          color: Colors.white,
          child: Column(
            /// 드라이브 메인 화면 드로워 컨테이너 내부 컬럼
            children: [
              Container(
                /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너
                padding:
                    EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
                child: Column(
                  /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 컬럼
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('메뉴',

                        /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 컬럼 타이틀
                        style: TextStyle(
                          /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 컬럼 타이틀 스타일
                          fontSize: 24,
                          color: Color(0xFF1A202C),
                          fontWeight: FontWeight.w700,
                        )),
                    SizedBox(height: 4),
                    Text('Menu',

                        /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 컬럼 서브타이틀
                        style: TextStyle(
                          /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 컬럼 서브타이틀 스타일
                          fontSize: 14,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              Expanded(
                /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildSectionHeader('학습 및 문제풀이', icon: Icons.menu_book),

                    /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 섹션 헤더
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '운전면허 문제은행',
                      subtitle: '예습 하기',
                      icon: Icons.school,
                      iconColor: Color(0xFF2563EB),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizNanum()));
                      },
                    ),
                    _buildDrawerItem(
                      /// 드라이브 메인 화면 드로워 컨테이너 내부 컨테이너 내부 리스트뷰 드로워 버튼
                      title: '문제풀이(quiz)',
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
                      title: '운전전문학원',
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
                      title: '운전면허 시험장',
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
                          // 위치 권한 확인 및 요청
                          var permissionStatus =
                              await Permission.location.status;
                          if (permissionStatus.isDenied ||
                              permissionStatus.isPermanentlyDenied) {
                            var requested = await Permission.location.request();
                            if (!requested.isGranted) {
                              _showErrorDialog(
                                  '위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.');
                              return;
                            }
                          }

                          // shimmer 효과 로딩 표시
                          Get.dialog(
                            _buildShimmerLoadingDialog(),
                            barrierDismissible: false,
                          );

                          // 병원 목록과 현재 위치를 병렬로 가져오기
                          final results = await Future.wait([
                            getHospitalList(),
                            Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high),
                          ]);

                          final hospitalList =
                              results[0] as List<HospitalModel>;
                          final currentPosition = results[1] as Position;

                          // 거리 계산 및 정렬 (HospitalModel의 내장 메서드 활용)
                          for (final hospital in hospitalList) {
                            hospital.distance =
                                hospital.calculateDistance(currentPosition);
                          }

                          hospitalList.sort((a, b) {
                            if (a.distance == null || b.distance == null) {
                              return 0;
                            }
                            return a.distance!.compareTo(b.distance!);
                          });

                          // 로딩 닫기
                          Get.back();

                          // 결과 페이지로 이동
                          Get.to(() => Hospital(hospitalList: hospitalList));
                        } on PermissionDeniedException {
                          Get.back(); // 로딩 닫기
                          _showErrorDialog(
                              '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.');
                        } on LocationServiceDisabledException {
                          Get.back(); // 로딩 닫기
                          _showErrorDialog(
                              '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
                        } catch (e) {
                          Get.back(); // 로딩 닫기
                          _showErrorDialog(
                              '병원 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
                          print('Error getting hospital list: $e');
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
      backgroundColor: Color(0xFFF7FAFC),
      body: SafeArea(

          /// 드라이브 메인 화면 바디
          child: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컬럼
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 섹션
                Container(
                  /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('운전면허 필기시험 문제풀이!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      )),
                ),
                SizedBox(height: 16),

                // 메인 버튼 그리드
                Row(
                  children: [
                    Expanded(
                      child: _buildMainButton(
                        title: '문제풀이',
                        subtitle: 'quiz',
                        icon: Icons.quiz,
                        color: Color(0xFFDBEAFE),
                        iconColor: Color(0xFF2563EB),
                        onTap: () async {
                          await context.setLocale(Locale("ko"));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainQuizNanum()));
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰
                      child: _buildMainButton(
                        title: '운전학원',
                        subtitle: 'academy',
                        icon: Icons.school,
                        color: Color(0xFFFED7AA),
                        iconColor: Color(0xFFEA580C),
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
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                      child: _buildMainButton(
                        title: '신체검사',
                        subtitle: 'hospital',
                        icon: Icons.local_hospital,
                        color: Color(0xFFFECACA),
                        iconColor: Color(0xFFDC2626),
                        onTap: () async {
                          try {
                            // 위치 권한 확인 및 요청
                            var permissionStatus =
                                await Permission.location.status;
                            if (permissionStatus.isDenied ||
                                permissionStatus.isPermanentlyDenied) {
                              var requested =
                                  await Permission.location.request();
                              if (!requested.isGranted) {
                                _showErrorDialog(
                                    '위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.');
                                return;
                              }
                            }

                            // shimmer 효과 로딩 표시
                            Get.dialog(
                              _buildShimmerLoadingDialog(),
                              barrierDismissible: false,
                            );

                            // 병원 목록과 현재 위치를 병렬로 가져오기
                            final results = await Future.wait([
                              getHospitalList(),
                              Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high),
                            ]);

                            final hospitalList =
                                results[0] as List<HospitalModel>;
                            final currentPosition = results[1] as Position;

                            // 거리 계산 및 정렬 (HospitalModel의 내장 메서드 활용)
                            for (final hospital in hospitalList) {
                              hospital.distance =
                                  hospital.calculateDistance(currentPosition);
                            }

                            hospitalList.sort((a, b) {
                              if (a.distance == null || b.distance == null) {
                                return 0;
                              }
                              return a.distance!.compareTo(b.distance!);
                            });

                            // 로딩 닫기
                            Get.back();

                            // 결과 페이지로 이동
                            Get.to(() => Hospital(hospitalList: hospitalList));
                          } on PermissionDeniedException {
                            Get.back(); // 로딩 닫기
                            _showErrorDialog(
                                '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.');
                          } on LocationServiceDisabledException {
                            Get.back(); // 로딩 닫기
                            _showErrorDialog(
                                '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
                          } catch (e) {
                            Get.back(); // 로딩 닫기
                            _showErrorDialog(
                                '병원 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
                            print('Error getting hospital list: $e');
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      /// 드라이브 메인 화면 바디 내부 컨테이너 내부 컨테이너 내부 컬럼 내부 리스트뷰 내부 리스트뷰
                      child: _buildMainButton(
                        title: '면허시험장',
                        subtitle: 'Test site',
                        icon: Icons.location_on,
                        color: Color(0xFFBBF7D0),
                        iconColor: Color(0xFF16A34A),
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
                  iconColor: Color(0xFF2563EB),
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
                          /// 신체검사 버튼 클릭 시 신체검사 지정병원 찾기
                          try {
                            // 위치 권한 확인 및 요청
                            var permissionStatus =
                                await Permission.location.status;
                            if (permissionStatus.isDenied ||
                                permissionStatus.isPermanentlyDenied) {
                              var requested =
                                  await Permission.location.request();
                              if (!requested.isGranted) {
                                _showErrorDialog(
                                    '위치 권한이 필요합니다.\n설정에서 위치 권한을 허용해주세요.');
                                return;
                              }
                            }

                            // shimmer 효과 로딩 표시
                            Get.dialog(
                              _buildShimmerLoadingDialog(),
                              barrierDismissible: false,
                            );

                            // 병원 목록과 현재 위치를 병렬로 가져오기
                            final results = await Future.wait([
                              getHospitalList(),
                              Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high),
                            ]);

                            final hospitalList =
                                results[0] as List<HospitalModel>;
                            final currentPosition = results[1] as Position;

                            // 거리 계산 및 정렬 (HospitalModel의 내장 메서드 활용)
                            for (final hospital in hospitalList) {
                              hospital.distance =
                                  hospital.calculateDistance(currentPosition);
                            }

                            hospitalList.sort((a, b) {
                              if (a.distance == null || b.distance == null)
                                return 0;
                              return a.distance!.compareTo(b.distance!);
                            });

                            // 로딩 닫기
                            Get.back();

                            // 결과 페이지로 이동
                            Get.to(() => Hospital(hospitalList: hospitalList));
                          } on PermissionDeniedException {
                            Get.back(); // 로딩 닫기
                            _showErrorDialog(
                                '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.');
                          } on LocationServiceDisabledException {
                            Get.back(); // 로딩 닫기
                            _showErrorDialog(
                                '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.');
                          } catch (e) {
                            Get.back(); // 로딩 닫기
                            _showErrorDialog(
                                '병원 정보를 불러오는 중 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
                            print('Error getting hospital list: $e');
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor),
            SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C))),
            SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    /// 운전면허 시험안내 버튼
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      /// 문제은행 버튼
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            SizedBox(width: 16),
            Expanded(
              /// 왼쪽 컬럼
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C))),
                  SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF718096)),
          ],
        ),
      ),
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
            border: Border.all(color: Colors.grey.shade200, width: 1),
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
                    color: Color(0xFF1A202C),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 4),
              Text(subtitle,

                  /// 캐러셀 버튼 서브타이틀
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF718096),
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
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0.1),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0.1),
        tileColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(icon, size: 18, color: iconColor),

        /// 드로워 버튼 아이콘
        title: Text(
          title,
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          /// 드로워 버튼 서브타이틀
          subtitle,
          style: TextStyle(
            color: Color(0xFF718096),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
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
            Icon(
              /// 섹션 헤더 아이콘
              icon,
              size: 16,
              color: Color(0xFF2563EB),
            ),
            SizedBox(width: 8),
          ],
          Text(
            /// 섹션 헤더 타이틀
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
          ),
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
}
