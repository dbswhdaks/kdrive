enum DriverLicenseType {
  /// 1종 보통
  type1Common('1종 보통', 40, 70),

  /// 2종 보통
  type2Common('2종 보통', 40, 60),

  /// 1종 대형
  type1Large('1종 대형', 40, 70),

  /// 1종 특수
  type1Special('1종 특수', 40, 70),

  /// 2종 소형
  type2Small('2종 소형', 40, 60),

  /// 원동기
  typeBike('원동기', 40, 60);

  /// 총 문항 수
  final String label;

  /// 총 문항 수
  final int totalQuestions;

  /// 합격 점수
  final int passingScore;

  const DriverLicenseType(this.label, this.totalQuestions, this.passingScore);
}
