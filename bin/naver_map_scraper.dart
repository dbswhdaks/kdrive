// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;
// import 'dart:io';

// class NaverMapScraper {
//   final String baseUrl = 'https://map.naver.com';

//   Future<List<String>> searchPlaces(String query) async {
//     try {
//       // 검색 요청 보내기
//       final response =
//           await http.get(Uri.parse('$baseUrl/search?query=$query'), headers: {
//         'User-Agent':
//             'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
//       });

//       if (response.statusCode == 200) {
//         // HTML 파싱
//         var document = parser.parse(response.body);

//         // 검색 결과 URL 추출
//         var searchResults = document.querySelectorAll('.search_box');
//         List<String> urls = [];

//         for (var result in searchResults) {
//           var link = result.querySelector('a');
//           if (link != null && link.attributes['href'] != null) {
//             urls.add(link.attributes['href']!);
//           }
//         }

//         return urls;
//       } else {
//         throw Exception('검색 요청 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('에러 발생: $e');
//       return [];
//     }
//   }
// }

// void main() async {
//   stdout.write('검색어를 입력하세요: ');
//   String query = stdin.readLineSync() ?? '';

//   if (query.isEmpty) {
//     print('검색어를 입력해주세요.');
//     return;
//   }

//   final scraper = NaverMapScraper();
//   final results = await scraper.searchPlaces(query);

//   if (results.isEmpty) {
//     print('검색 결과가 없습니다.');
//   } else {
//     print('\n검색 결과 URL:');
//     for (var url in results) {
//       print(url);
//     }
//   }
// }
