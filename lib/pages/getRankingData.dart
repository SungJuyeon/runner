import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 사용
import 'dart:html' as html; //웹 콘솔 출력

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

// 유저의 imgNum을 가져오는 함수 (character 필드 사용)
Future<int> getUserImgNum(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 유저 정보 가져오기 (userId를 사용)
  DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

  // 유저의 character가 존재하면 반환, 없으면 기본값 3을 반환
  if (userDoc.exists && userDoc.data() != null) {
    return userDoc['character'] ?? 3; // character 필드가 없으면 기본값 3
  } else {
    return 3; // 기본값 3
  }
}

// 일일 랭킹을 반환하는 함수
Future<List<Map<String, dynamic>>> getDailyRanking() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  DateTime startOfDay = getStartOfDay(now);

  // 일일 데이터 가져오기
  QuerySnapshot snapshot = await firestore
      .collection('trueRecode')
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();

  // 닉네임별로 count 합산
  Map<String, int> ranking = {};
  for (var doc in snapshot.docs) {
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

  // imgNum을 비동기적으로 가져오기 위해 Future.wait을 사용
  List<Future> futures = [];
  List<Map<String, dynamic>> rankingData = [];

  // imgNum을 비동기적으로 가져오기 위해 Future.wait을 사용
  for (var entry in sortedRanking) {
    futures.add(
      getUserImgNum(entry.key).then((imgNum) {
        // imgNum을 가져온 후 rankingData에 추가
        rankingData.add({
          'name': entry.key,  // 닉네임
          'score': entry.value,  // 점수
          'imgNum': imgNum,  // 유저의 imgNum
        });
      }),
    );
  }

  // 모든 비동기 작업 완료 후 순위를 부여
  await Future.wait(futures);

  // 순위 부여
  for (int i = 0; i < rankingData.length; i++) {
    rankingData[i]['rank'] = i + 1;  // 순위는 1부터 시작
  }

  // rankingData 출력 (웹에서만 사용)
  html.window.console.log("일일 랭킹 데이터: $rankingData");

  return rankingData;
}

// 주간 랭킹을 반환하는 함수 (월간 랭킹 함수와 비슷한 방식)
Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  DateTime startOfWeek = getStartOfWeek(now);

  // 주간 데이터 가져오기
  QuerySnapshot snapshot = await firestore
      .collection('trueRecode')
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
      .get();

  // 닉네임별로 count 합산
  Map<String, int> ranking = {};
  for (var doc in snapshot.docs) {
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

  // imgNum을 비동기적으로 가져오기 위해 Future.wait을 사용
  List<Future> futures = [];
  List<Map<String, dynamic>> rankingData = [];

  // imgNum을 비동기적으로 가져오기 위해 Future.wait을 사용
  for (var entry in sortedRanking) {
    futures.add(
      getUserImgNum(entry.key).then((imgNum) {
        // imgNum을 가져온 후 rankingData에 추가
        rankingData.add({
          'name': entry.key,  // 닉네임
          'score': entry.value,  // 점수
          'imgNum': imgNum,  // 유저의 imgNum
        });
      }),
    );
  }

  // 모든 비동기 작업 완료 후 순위를 부여
  await Future.wait(futures);

  // 순위 부여
  for (int i = 0; i < rankingData.length; i++) {
    rankingData[i]['rank'] = i + 1;  // 순위는 1부터 시작
  }

  // rankingData 출력 (웹에서만 사용)
  html.window.console.log("주간 랭킹 데이터: $rankingData");

  return rankingData;
}


// 월간 랭킹을 반환하는 함수
Future<List<Map<String, dynamic>>> getMonthlyRanking() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  DateTime startOfMonth = getStartOfMonth(now);

  // 월간 데이터 가져오기
  QuerySnapshot snapshot = await firestore
      .collection('trueRecode')
      .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .get();

  // 닉네임별로 count 합산
  Map<String, int> ranking = {};
  for (var doc in snapshot.docs) {
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

  // imgNum을 비동기적으로 가져오기 위해 Future.wait을 사용
  List<Future> futures = [];
  List<Map<String, dynamic>> rankingData = [];

  // imgNum을 비동기적으로 가져오기 위해 Future.wait을 사용
  for (var entry in sortedRanking) {
    futures.add(
      getUserImgNum(entry.key).then((imgNum) {
        // 순위를 부여하고 데이터 추가 (순위 부여는 비동기 후에 처리)
        rankingData.add({
          'name': entry.key,  // 닉네임
          'score': entry.value,  // 점수
          'imgNum': imgNum,  // 유저의 imgNum
        });
      }),
    );
  }

  // 모든 비동기 작업 완료 후 순위를 부여
  await Future.wait(futures);

  // 순위를 부여
  for (int i = 0; i < rankingData.length; i++) {
    rankingData[i]['rank'] = i + 1;  // 순위는 1부터 시작
  }

  // rankingData 출력 (웹에서만 사용)
  html.window.console.log("월간 랭킹 데이터: $rankingData");

  return rankingData;
}
