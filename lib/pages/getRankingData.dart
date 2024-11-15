import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 사용
//import 'dart:html' as html; //웹 콘솔 출력

// 탭 별로 날짜 범위를 정하기 위해 사용되는 함수들
// 범위의 시작 날짜 및 시간을 세팅 (주간이면 사용 날짜의 첫날인 월요일을 리턴, 일일은 하루의 시작 시간인 자정을 리턴)
DateTime getStartOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day); // 자정 시간으로 설정
}

DateTime getStartOfWeek(DateTime date) {
  DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1)); // 이번 주 첫 날 (월요일)
  return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
}

DateTime getStartOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1); // 이번 달 첫 날
}

// 유저의 imgNum을 가져오는 함수 (nickname 필드 사용)
Future<int> getUserImgNum(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // nickname 필드가 userId와 일치하는 문서 쿼리
  QuerySnapshot querySnapshot = await firestore
      .collection('users')
      .where('nickname', isEqualTo: userId)
      .limit(1)
      .get();

  // 해당하는 문서가 있는지 확인하고, character 필드를 반환
  if (querySnapshot.docs.isNotEmpty) {
    var userDoc = querySnapshot.docs.first;
    //html.window.console.log("userId: $userId character: ${userDoc['character']}");
    return userDoc['character'] ?? 3; // character 필드가 없으면 기본값 3
  } else {
    //html.window.console.log("No data found for userId: $userId");
    return 3; // 기본값 3
  }
}
// 일일 랭킹을 반환하는 함수
Future<List<Map<String, dynamic>>> getDailyRanking() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  DateTime startOfDay = getStartOfDay(now);

  // 일일 데이터 가져오기
  QuerySnapshot snapshotDaily = await firestore
      .collection('trueRecord')
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();

  // 닉네임별로 count 합산
  Map<String, int> ranking = {};
  for (var doc in snapshotDaily.docs) {
    String nickname = doc['nickname'];
    int count = doc['count'];  // count가 int 타입인지 확인

    // 닉네임 별로 count 합산
    if (ranking.containsKey(nickname)) {
      ranking[nickname] = ranking[nickname]! + count;
    } else {
      ranking[nickname] = count;
    }
  }

  // 랭킹을 내림차순으로 정렬
  var sortedRanking = ranking.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)); // 내림차순 정렬

  //html.window.console.log("일간 정렬된 랭킹: $sortedRanking");

  List<Map<String, dynamic>> rankingData = [];
  int rank = 1;

  for (var entry in sortedRanking) {
    // imgNum을 비동기적으로 가져와서 순차적으로 리스트에 추가
    var imgNum = await getUserImgNum(entry.key);
    rankingData.add({
      'name': entry.key,  // 닉네임
      'score': entry.value,  // 점수
      'imgNum': imgNum,  // 유저의 imgNum
      'rank': rank++,  // 순위는 1부터 시작
    });
  }

  // rankingData 출력 (웹에서만 사용)
  //html.window.console.log("일일 랭킹 데이터: $rankingData");

  return rankingData;
}

// 주간 랭킹을 반환하는 함수
Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  DateTime startOfWeek = getStartOfWeek(now);

  // 주간 데이터 가져오기
  QuerySnapshot snapshotWeek = await firestore
      .collection('trueRecord')
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
      .get();

  // 닉네임별로 count 합산
  Map<String, int> ranking = {};
  for (var doc in snapshotWeek.docs) {
    String nickname = doc['nickname'];
    int count = doc['count'];  // count가 int 타입인지 확인

    // 닉네임 별로 count 합산
    if (ranking.containsKey(nickname)) {
      ranking[nickname] = ranking[nickname]! + count;
    } else {
      ranking[nickname] = count;
    }
  }

  // 랭킹을 내림차순으로 정렬
  var sortedRanking = ranking.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)); // 내림차순 정렬

  //html.window.console.log("주간 정렬된 랭킹: $sortedRanking");

  List<Map<String, dynamic>> rankingData = [];
  int rank = 1;

  for (var entry in sortedRanking) {
    // imgNum을 비동기적으로 가져와서 순차적으로 리스트에 추가
    var imgNum = await getUserImgNum(entry.key);
    rankingData.add({
      'name': entry.key,  // 닉네임
      'score': entry.value,  // 점수
      'imgNum': imgNum,  // 유저의 imgNum
      'rank': rank++,  // 순위는 1부터 시작
    });
  }

  // rankingData 출력 (웹에서만 사용)
  //html.window.console.log("주간 랭킹 데이터: $rankingData");

  return rankingData;
}


// 월간 랭킹을 반환하는 함수
Future<List<Map<String, dynamic>>> getMonthlyRanking() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  DateTime startOfMonth = getStartOfMonth(now);

  // 월간 데이터 가져오기
  QuerySnapshot snapshotMonth = await firestore
      .collection('trueRecord')
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .get();

  // 닉네임별로 count 합산
  Map<String, int> ranking = {};
  for (var doc in snapshotMonth.docs) {
    String nickname = doc['nickname'];
    int count = doc['count'];

    // 닉네임 별로 count 합산
    if (ranking.containsKey(nickname)) {
      ranking[nickname] = ranking[nickname]! + count;
    } else {
      ranking[nickname] = count;
    }
  }

  // 랭킹을 내림차순으로 정렬
  var sortedRanking = ranking.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value)); // 내림차순 정렬

  //html.window.console.log("월간 정렬된 랭킹: $sortedRanking");

  // sortedRanking에 imgNum과 순위를 추가하는 코드
  int rank = 1;  // 순위는 1부터 시작
  List<Map<String, dynamic>> updatedRanking = [];  // 최종 반환할 리스트 형태

  for (var entry in sortedRanking) {
    // getUserImgNum(entry.key)는 비동기 함수이므로 await 사용
    var imgNum = await getUserImgNum(entry.key);

    // imgNum과 rank를 포함한 새 데이터를 updatedRanking에 추가
    updatedRanking.add({
      'name': entry.key,        // 닉네임
      'score': entry.value,     // 점수
      'imgNum': imgNum,         // 유저의 imgNum
      'rank': rank,             // 순위
    });

    rank++;  // 다음 항목에 대한 순위를 증가시킴
  }

  // rankingData 출력 (웹에서만 사용)
  //html.window.console.log("월간 랭킹 데이터: $updatedRanking");

  return updatedRanking; // List<Map<String, dynamic>> 타입으로 반환
}
