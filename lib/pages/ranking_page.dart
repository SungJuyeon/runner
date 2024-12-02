import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'navigationBar.dart';
import 'package:runner/pages/makingImage.dart';
import 'package:runner/pages/getRankingData.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지
//import 'package:runner/pages/loading.dart';
import 'package:flutter/foundation.dart'; //로그 출력
//import 'dart:html' as html; //웹 콘솔 출력

// 로그에 태그를 추가해서 필터링할 수 있게하는 함수
void printLog(String message, String tag) {
  debugPrint('$tag: $message'); // debugPrint를 사용하여 로그를 태그와 함께 출력
}

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? nickname; // 닉네임 변수 추가
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 색상 정의
  final Color yellowColor = Color(0xFFEEEB96);
  final Color blueColor = Color(0xFF66A2FD);

  // 탭 이름 배열
  final List<String> tabNames = ['일일', '주간', '월간'];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _fetchNickname();

    // 탭 변경 시 상태 업데이트
    _tabController.addListener(() {
      setState(() {}); // UI를 새로 고침
    });
  }


  // Firestore에서 닉네임을 가져오는 메서드
  Future<void> _fetchNickname() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        nickname = userDoc['nickname'] ?? "Guest"; // 닉네임이 없으면 기본값 'Guest'로 설정
      });
      //html.window.console.log("_fetchNickname 안에서 받은 닉네임: $nickname");
    }
  }

  @override
  void dispose() {
    _tabController.dispose(); // 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery로 화면 크기 정보를 가져오기
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('랭킹', style: TextStyle(color: Colors.black)),
        // 상단바 제목 설정
        backgroundColor: Colors.white,
        // 배경색 흰색
        centerTitle: true,
        // 제목 중앙 정렬
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로 가기 버튼
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          // 탭 컨트롤러 설정
          labelColor: Colors.black,
          // 선택된 탭 글자 색상
          unselectedLabelColor: Colors.grey,
          // 선택되지 않은 탭 글자 색상
          indicatorColor: blueColor,
          // 탭 하단의 인디케이터 색상
          tabs: [
            Tab(text: '일일'), // 일일 탭
            Tab(text: '주간'), // 주간 탭
            Tab(text: '월간'), // 월간 탭
          ],
        ),
      ),
      body: Column(
        children: [
          // 탭 선택에 따라 다른 랭킹 콘텐츠 표시
          Expanded(
            child: TabBarView(
              controller: _tabController, // 탭 컨트롤러 사용
              children: [
                buildRankingContent('일일'), // 일일 랭킹 콘텐츠
                buildRankingContent('주간'), // 주간 랭킹 콘텐츠
                buildRankingContent('월간'), // 월간 랭킹 콘텐츠
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: buildCurrentUserRankingTile(nickname), // 현재 사용자 랭킹 타일
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context), // 하단 네비게이션 바
    );
  }

  // 탭 이름에 따라 랭킹 데이터를 반환하는 함수
  Future<List<Map<String, dynamic>>> getRankingData(String tabName) async {
    if (tabName == '일일') { // 일일 랭킹 데이터
      return await getDailyRanking();
    } else if (tabName == '주간') { // 주간 랭킹 데이터
      return await getWeeklyRanking();
    } else { // 월간 랭킹 데이터
      return await getMonthlyRanking();
    }
  }

  // 랭킹 콘텐츠를 생성하는 위젯 (탭에 따른 데이터 사용)
  Widget buildRankingContent(String tabName) {
    // Future로 랭킹 데이터를 가져오는 부분
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getRankingData(tabName), // 비동기 데이터 가져오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 데이터 로딩 중일 때 로딩 인디케이터 표시
        } else if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}')); // 오류 발생 시 메시지 표시
        //} else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //return Center(child: Text('데이터가 없습니다.')); // 데이터가 없을 경우
        } else {
          final rankingData = snapshot.data!; // 데이터가 있을 경우

          // 최소 3개의 데이터를 유지하기 위해 부족한 경우 빈 데이터를 추가
          if (rankingData.length < 3) {
            // 현재 있는 데이터의 개수에서 다음 rank 시작 번호를 계산
            int nextRank = rankingData.length + 1;
            //html.window.console.log("데이터 부족으로 생성된 순위(nextRank): $nextRank");

            rankingData.addAll(List.generate(
              3 - rankingData.length, // 필요한 데이터 개수만큼 빈 데이터 생성
                  (index) => {
                'rank': nextRank + index, // rank 값은 1부터 차례로 설정
                'name': '기록이 없습니다.',
                'imgNum': 1,
                'score': -1,
              },
            ));
          }

          // rank 값을 숫자로 변환하여 정렬 (탭에 맞게 순위가 바뀌어야 하므로)
          rankingData.sort((a, b) => int.parse(a['rank'].toString()).compareTo(int.parse(b['rank'].toString())));
          //html.window.console.log("rankingData: $rankingData");

          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 16), // 간격 추가
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: buildHighRanker(
                          rankingData[1]['rank'],
                          rankingData[1]['name'],
                          rankingData[1]['imgNum'],
                          rankingData[1]['score'],
                          tabName,
                        ),
                      ),
                      Flexible(
                        child: buildHighRanker(
                          rankingData[0]['rank'],
                          rankingData[0]['name'],
                          rankingData[0]['imgNum'],
                          rankingData[0]['score'],
                          tabName,
                        ),
                      ),
                      Flexible(
                        child: buildHighRanker(
                          rankingData[2]['rank'],
                          rankingData[2]['name'],
                          rankingData[2]['imgNum'],
                          rankingData[2]['score'],
                          tabName,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rankingData.length,
                      itemBuilder: (context, index) {
                        return buildRankList(
                          rankingData[index]['rank'],
                          rankingData[index]['name'],
                          rankingData[index]['score'],
                          yellowColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }


  // 상위 랭커 빌드 함수 (이미지 및 정보 표시)
  Widget buildHighRanker(int rank, String name, int imgNum, int score,
      String tabName) {
    double avatarRadius = 30; // 프로필 사진 원형 크기
    double textSize = 20; // 텍스트 크기
    Color bgColor = yellowColor;
    double imageSize;
    String assetPath; // 캐릭터 이미지

    // 랭크에 따른 이미지 크기 조정
    if (rank == 1) {
      imageSize = 160;
    } else if (rank == 2) {
      imageSize = 110;
    } else {
      imageSize = 90;
    }

    // 사용자 별 캐릭터 이미지 설정
    if (imgNum == 1) {
      assetPath = 'assets/image/learnerBear.png';
    } else if (imgNum == 2) {
      assetPath = 'assets/image/learnerBrown.png';
    } else {
      assetPath = 'assets/image/learnerRabbit.png';
    }

    // score가 -1이면 투명 처리
    if (score == -1) {
      //html.window.console.log("score가 -1로 조건문 안으로 들어옴(투명화)");
      return Opacity(
        opacity: 0.0, // 투명 처리
        child: Column(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: bgColor,
              child: Center(
                child: Text(
                  rank.toString(),
                  style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 8),
            Image.asset(assetPath, height: imageSize, width: imageSize),
            SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(score.toString(), style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    // score가 -1이 아닌 경우 일반적인 처리
    return Column(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: bgColor,
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 8),
        Image.asset(assetPath, height: imageSize, width: imageSize),
        // 이미지 표시
        SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        // 이름 표시
        SizedBox(height: 4),
        Text(score.toString(), style: TextStyle(fontSize: 16)),
        // 점수 표시
      ],
    );
  }

  // 일반 랭킹 리스트 빌드 함수
  Widget buildRankList(int rank, String name, int score, Color bgColor) {
    // score가 -1이면 빈 공간 반환
    if (score == -1) {
      return SizedBox.shrink(); // 아무 것도 렌더링하지 않음
    }

    return Container(
      decoration: BoxDecoration(
        color: yellowColor,
        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
      ),
      margin: EdgeInsets.symmetric(vertical: 7), // 위아래 여백
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), // 내부 여백
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Text(rank.toString(),
                  style: TextStyle(color: Colors.black)), // 순위 표시
            ),
            SizedBox(width: 4),
            Text(name, style: TextStyle(fontSize: 17),
                textAlign: TextAlign.center), // 이름 표시
            SizedBox(width: 4),
            Text(score.toString(), style: TextStyle(fontSize: 17)), // 점수 표시
          ],
        ),
      ),
    );
  }

  // 하단 네비게이션 바
  Widget buildBottomNavigationBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () => onRankingPressed(context), // "랭킹" 버튼의 onTap 함수 호출
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.leaderboard),
                    Text('랭킹'),
                  ],
                ),
              ),
              const SizedBox(width: 48), // 홈 버튼 공간 확보
              InkWell(
                onTap: () => onProfilePressed(context), // "마이" 버튼의 onTap 함수 호출
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.person),
                    Text('마이'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 15, // 홈 버튼 원 위치 조정
          child: InkWell(
            onTap: () => onHomePressed(context), // "홈" 버튼의 onTap 함수 호출
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF66A2FD),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const[
                  Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 40,
                  ),
                  Text(
                    '홈',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 현재 사용자 등수를 가져와 표시하는 함수
  Widget buildCurrentUserRankingTile(String? name) {
    //html.window.console.log("현재유저 타일의 인자로 들어온 닉네임: $name");

    String selectedTabName = _tabController.index == 0
        ? '일일'
        : (_tabController.index == 1 ? '주간' : '월간');

    // FutureBuilder로 비동기 데이터를 처리
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getRankingData(selectedTabName), // 비동기 데이터 가져오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 데이터 로딩 중일 때 로딩 인디케이터 표시
        } else if (snapshot.hasError) {
          return Center(child: Text('오류 발생: ${snapshot.error}')); // 오류 발생 시 메시지 표시
        //} else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //return Center(child: Text('데이터가 없습니다.')); // 데이터가 없을 경우
        } else {
          // snapshot.data는 랭킹 데이터
          List<Map<String, dynamic>> rankingData = snapshot.data!;

          // 현재 사용자의 등수 찾기
          Map<String, dynamic>? currentUserData = rankingData.firstWhere(
                (user) => user['name'] == name,
            orElse: () => {'rank': '-', 'name': '-', 'score': 0, 'imgNum': 1},
          );

          return InkWell(
            onTap: () {
              // 클릭 시 새로운 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MakingImage(
                    rank: currentUserData['rank'],
                    score: currentUserData['score'],
                    name: name ?? 'Unkown',
                    imgNum: currentUserData['imgNum'],
                    tabName: getCurrentTabName(),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: blueColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentUserData['rank']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${currentUserData['name']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '${currentUserData['score']}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }


  // 현재 탭의 이름 반환
  String getCurrentTabName() {
    return tabNames[_tabController.index]; // Get tab name by index
  }
}
