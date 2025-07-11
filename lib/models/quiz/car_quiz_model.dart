import 'dart:convert';
import 'package:kdrive/main.dart';
import 'package:kdrive/models/quiz/quiz_model.dart';

enum CarQuizLanguage {
  korea(tableName: 'korea_car'),
  english(tableName: 'english_car'),
  china(tableName: 'china_car'),
  vietnam(tableName: 'vietnam_car');

  final String tableName;

  const CarQuizLanguage({required this.tableName});
}

/// korea_car 테이블에서 id가 1인 컬럼 가져오기
Future<CarQuizModel?> getKoreaCarById(int id) async {
  try {
    var result =
        await supabase.from('korea_car').select().eq('id', id).single();

    print('korea_car 테이블 id $id 조회 결과: $result');
    return CarQuizModel.fromMap(result);
  } catch (e) {
    print('korea_car 테이블 id $id 조회 오류: $e');
    return null;
  }
}

/// korea_car 테이블에서 id가 1인 컬럼 가져오기 (특정 id)
Future<CarQuizModel?> getKoreaCarByIdOne() async {
  return await getKoreaCarById(1);
}

/// 퀴즈목록 가져오기
Future<List<CarQuizModel>> getCarQuizList(CarQuizLanguage language) async {
  var result = await supabase
      .from(language.tableName)
      .select()
      .order('id', ascending: false);
  print(result);
  List<CarQuizModel> quizList =
      result.map((e) => CarQuizModel.fromMap(e)).toList();

  // 문제 불러와서 100점으로 세팅
  // a.문장형         (17문제)        4지 1답 2점 1~40번   =34점
  // b.문장형         (4문제)         4지 2답 3점 41~52번  =12점
  // c.사진형         (6문제)         5지 2답 3점 53~65번  =18점
  // d.일러스트       (7문제)         5지 2답 3점 66~80번  =21점
  // e.안전표지판형   (5문제)         4지 1답 2점 81~92번  =10점
  // f.동영상형       (1문제)         4지 1답 5점 93~100번  =5점
  // 합계 100점

  List<CarQuizModel> aList = [];
  List<CarQuizModel> bList = [];
  List<CarQuizModel> cList = [];
  List<CarQuizModel> dList = [];
  List<CarQuizModel> eList = [];
  List<CarQuizModel> fList = [];

  // 유형별 문제 저장
  for (CarQuizModel quiz in quizList) {
    if (quiz.division == 'a') {
      aList.add(quiz);
    }
    if (quiz.division == 'b') {
      bList.add(quiz);
    }
    if (quiz.division == 'c') {
      cList.add(quiz);
    }
    if (quiz.division == 'd') {
      dList.add(quiz);
    }
    if (quiz.division == 'e') {
      eList.add(quiz);
    }
    if (quiz.division == 'f') {
      fList.add(quiz);
    }
  }

  // 문제를 석어서 갯수에 맞게 가져오는 방법
  aList.shuffle();
  aList = aList.sublist(0, 17);

  bList.shuffle();
  bList = bList.sublist(0, 4);

  cList.shuffle();
  cList = cList.sublist(0, 6);

  dList.shuffle();
  dList = dList.sublist(0, 7);

  eList.shuffle();
  eList = eList.sublist(0, 5);

  fList.shuffle();
  fList = fList.sublist(0, 1);

  // 모든문제 합산
  List<CarQuizModel> newQuizList = [
    ...aList,
    ...bList,
    ...cList,
    ...dList,
    ...eList,
    ...fList,
  ];

  return newQuizList;
}

class CarQuizModel extends QuizModel {
  CarQuizModel({
    required super.id,
    required super.question,
    required super.bogi,
    required super.example,
    required super.answer,
    required super.score,
    required super.division,
    required super.problemtype,
    required super.image,
    required super.video,
    required super.language,
  });
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "question": question,
      "bogi": bogi,
      "example": example,
      "answer": answer,
      "score": score,
      "division": division,
      "image": image,
      "video": video,
      "problemtype": problemtype,
      "language": language,
    };
  }

  factory CarQuizModel.fromMap(Map<String, dynamic> map) {
    return CarQuizModel(
      id: map["id"]?.toInt(),
      question: map["question"],
      bogi: map["bogi"] == null ? null : List<String>.from(map["bogi"]),
      example: List<String>.from(map["example"]),
      answer: List<int>.from(map["answer"]),
      score: map["score"]?.toInt(),
      division: map["division"],
      problemtype: map["problemtype"],
      image: map["image"],
      video: map["video"],
      language: map["language"] ?? "korea",
    );
  }

  String toJson() => json.encode(toMap());

  factory CarQuizModel.fromJson(String source) =>
      CarQuizModel.fromMap(json.decode(source));
}
