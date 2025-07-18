// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdrive/drive_main.dart';
import 'package:kdrive/generated/locale_keys.g.dart';
import 'package:kdrive/models/quiz_model/bike_quiz_model.dart';
import 'package:kdrive/models/quiz_model/car_quiz_model.dart';
import 'package:kdrive/models/quiz_model/quiz_model.dart';
import 'package:kdrive/quiz/replay_screen.dart';
import 'package:kdrive/quiz/replay_screen_bike.dart';
import 'package:kdrive/utils/drive_license_type.dart';

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({
    super.key,
    required this.quizList,
    required this.myAnswers,
    required this.licenseType,
  });

  ///데이터 받고 생성자

  final List<QuizModel> quizList;
  final List<List<int>> myAnswers;
  final DriverLicenseType licenseType;

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < quizList.length; i++) {
      final sortedMyAnswer = List<int>.from(myAnswers[i])..sort();
      if (listEquals(quizList[i].answer, sortedMyAnswer)) {
        score = score + quizList[i].score!;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();
    final isPassed = score >= licenseType.passingScore;
    final totalQuestions = quizList.length;
    final correctAnswers = quizList.where((quiz) {
      final index = quizList.indexOf(quiz);
      final sortedMyAnswer = List<int>.from(myAnswers[index])..sort();
      return listEquals(quiz.answer, sortedMyAnswer);
    }).length;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
          ),
          title: Text(
            '${_getLicenseTypeText()} ${LocaleKeys.quiz_result.tr()}',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 점수 표시 섹션
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPassed
                        ? const [Color(0xFF4CAF50), Color(0xFF45A049)]
                        : const [Color(0xFFF44336), Color(0xFFD32F2F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      isPassed
                          ? Icons.celebration
                          : Icons.sentiment_dissatisfied,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      isPassed
                          ? LocaleKeys.passed.tr()
                          : LocaleKeys.failed.tr(),
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${LocaleKeys.your_score.tr(namedArgs: {
                            "score": score.toString()
                          })}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$correctAnswers / $totalQuestions 정답',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 홈으로 돌아가기 버튼
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () => Get.offAll(Drive_Main()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 20),
                      SizedBox(width: 8),
                      Text(
                        LocaleKeys.back_to_home.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // 문제 목록 제목
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Icon(Icons.list_alt, color: Color(0xFF667eea), size: 24),
                    SizedBox(width: 8),
                    Text(
                      '문제 목록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 문제 목록
              ListView.separated(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: quizList.length,
                itemBuilder: (context, index) {
                  final quizModel = quizList[index];
                  if (quizModel is CarQuizModel) {
                    return ItemWidget(
                      index: index,
                      quizModel: quizModel,
                      myAnswer: myAnswers[index],
                      isBike: false,
                    );
                  } else if (quizModel is BikeQuizModel) {
                    return ItemWidget(
                      index: index,
                      quizModel: quizModel,
                      myAnswer: myAnswers[index],
                      isBike: true,
                    );
                  }
                  return SizedBox.shrink();
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 6);
                },
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getLicenseTypeText() {
    // 라이선스 타입 텍스트 반환
    switch (licenseType) {
      case DriverLicenseType.type1Common:
        return LocaleKeys.class_1_driver_license.tr();
      case DriverLicenseType.type2Common:
        return LocaleKeys.class_2_driver_license.tr();
      case DriverLicenseType.typeBike:
        return LocaleKeys.class_bike.tr();
    }
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.index,
    required this.quizModel,
    required this.myAnswer,
    required this.isBike,
  });

  final int index;
  final QuizModel quizModel;
  final List<int> myAnswer;
  final bool isBike;

  @override
  Widget build(BuildContext context) {
    final sortedMyAnswer = List<int>.from(myAnswer)..sort();
    final isCorrect = listEquals(quizModel.answer, sortedMyAnswer);

    // compact 스타일 값(항상 적용)
    const double cardPadding = 6;
    const double numberBox = 30;
    const double fontSize = 18;
    const double iconSize = 13;
    const double buttonFont = 13;
    const double buttonPadH = 6;
    const double buttonPadV = 4;
    const double gap = 8;

    return Container(
      // 문제 컨테이너
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            // 문제 번호
            Container(
              width: numberBox,
              height: numberBox,
              decoration: BoxDecoration(
                color: isCorrect ? Color(0xFF4CAF50) : Color(0xFFF44336),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(width: gap),

            // 답안 선택지들
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...List.generate(
                    quizModel.example.length,
                    (choiceIndex) {
                      int number = choiceIndex + 1;
                      final isAnswer = quizModel.answer.contains(number);
                      final isMyChoice = myAnswer.contains(number);

                      return NumBerWidget(
                        number: number,
                        type: isAnswer ? AnswerType.correct : AnswerType.basic,
                        isSelected: isMyChoice,
                        isWrong: isMyChoice && !isAnswer,
                      );
                    },
                  )
                ],
              ),
            ),

            SizedBox(width: gap),

            // 결과 아이콘
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Color(0xFF4CAF50) : Color(0xFFF44336),
              size: iconSize,
            ),

            SizedBox(width: gap / 2),

            // 상세보기 버튼
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF667eea),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    if (isBike) {
                      Get.to(ReplayScreenBike(
                        quizModel: quizModel as BikeQuizModel,
                        myAnswer: myAnswer,
                        index: index,
                      ));
                    } else {
                      Get.to(ReplayScreen(
                        quizModel: quizModel as CarQuizModel,
                        myAnswer: myAnswer,
                        index: index,
                      ));
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: buttonPadH, vertical: buttonPadV),
                    child: Text(
                      LocaleKeys.check.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: buttonFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumBerWidget extends StatelessWidget {
  const NumBerWidget({
    super.key,
    required this.number,
    this.type = AnswerType.basic,
    this.isSelected = false,
    this.isWrong = false,
  });

  final int number;
  final AnswerType type;
  final bool isSelected;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    Color borderColor = Color(0xFFE0E0E0);
    Color textColor = Color(0xFF757575);

    if (isSelected && isWrong) {
      backgroundColor = Color(0xFFF44336);
      borderColor = Color(0xFFF44336);
      textColor = Colors.white;
    } else if (isSelected && type == AnswerType.correct) {
      backgroundColor = Color(0xFF4CAF50);
      borderColor = Color(0xFF4CAF50);
      textColor = Colors.white;
    } else if (type == AnswerType.correct) {
      backgroundColor = Color(0xFF4CAF50).withOpacity(0.1);
      borderColor = Color(0xFF4CAF50);
      textColor = Color(0xFF4CAF50);
    }

    // compact 스타일(항상 적용)
    const double boxSize = 34;
    const double fontSize = 19;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

enum AnswerType {
  /// 기본
  basic(Colors.grey),

  /// 정답
  correct(Colors.green);

  final Color color;

  const AnswerType(this.color);
}
