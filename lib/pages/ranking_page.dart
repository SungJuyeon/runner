import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'navigationBar.dart';
import 'package:runner/pages/makingImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지
import 'package:runner/pages/loading.dart';
import 'package:flutter/foundation.dart'; //로그 출력

// 로그에 태그를 추가해서 필터링할 수 있게하는 함수
void printLog(String message, String tag) {
  debugPrint('$tag: $message'); // debugPrint를 사용하여 로그를 태그와 함께 출력
}

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? nickname; // 닉네임을 저장할 변수
  bool _isLoading = true; // 로딩 상태
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

    // Firestore에서 닉네임을 동기적으로 가져오는 메서드 호출
    _fetchNickname();

    // 탭 변경 시 상태 업데이트
    _tabController.addListener(() {
      setState(() {}); // UI를 새로 고침
    });
  }

  // // Firestore에서 닉네임을 동기적으로 가져오는 메서드
  // Future<void> _fetchNickname() async {
  //   try {
  //     // Firestore에서 닉네임을 가져오는 코드
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('users') //'users' 컬렉션
  //         .doc('user_id') // 'user_id' 문서
  //         .get(); // 문서에서 가져오기
  //
  //     setState(() {
  //       _nickname = snapshot['nickname'] ?? 'Unknown'; // 닉네임 설정
  //       _isLoading = false; // 로딩 상태 변경
  //     });
  //
  //
  //   } catch (e) {
  //     setState(() {
  //       _nickname = 'Unknown'; // 에러 발생 시 기본값 설정
  //       _isLoading = false; // 로딩 상태 변경
  //     });
  //
  //     // 에러 로그 출력
  //     printLog("Nickname from Firebase: $_nickname", "FirebaseNickname");
  //   }
  // }

  void _fetchNickname() {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).get().then((userDoc) {
        setState(() {
          nickname = userDoc['nickname'] ?? "Guest"; // 닉네임이 없으면 기본값 'Guest'로 설정
          _isLoading = false; // 로딩 상태 변경
        });
      }).catchError((e) {
        // 오류 처리
        setState(() {
          nickname = "Guest"; // 오류가 발생하면 기본값 'Guest'로 설정
          _isLoading = false; // 로딩 상태 변경
        });
      });
    }
  }



  @override
  void dispose() {
    _tabController.dispose(); // 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 닉네임이 로드되기 전에 로딩 화면을 표시
      return Scaffold(
        body: LoadingScreen(), // LoadingPage는 별도의 로딩 화면 위젯
      );
    }

    // 로딩 끝난 후 화면
    return Scaffold(
      appBar: AppBar(
        title: Text('랭킹', style: TextStyle(color: Colors.black)), // 상단바 제목 설정
        backgroundColor: Colors.white, // 배경색 흰색
        centerTitle: true, // 제목 중앙 정렬
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로 가기 버튼
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 돌아가기
          },
        ),
        bottom: TabBar(
          controller: _tabController, // 탭 컨트롤러 설정
          labelColor: Colors.black, // 선택된 탭 글자 색상
          unselectedLabelColor: Colors.grey, // 선택되지 않은 탭 글자 색상
          indicatorColor: blueColor, // 탭 하단의 인디케이터 색상
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
            child: buildCurrentUserRankingTile(nickname ?? 'Unknown'), // nickname이 null일 경우 'Unknown' 사용
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context), // 하단 네비게이션 바
    );
  }

  // 탭 이름에 따라 랭킹 데이터를 반환하는 함수
  List<Map<String, dynamic>> getRankingData(String tabName) {
    if (tabName == '일일') { // 일일 랭킹 데이터
      return [
        {'rank': 1, 'name': 'Juyeon', 'score': 17, 'imgNum': 3},
        {'rank': 2, 'name': 'Yujin', 'score': 15, 'imgNum': 2},
        {'rank': 3, 'name': 'Hajin', 'score': 14, 'imgNum': 3},
        {'rank': 4, 'name': 'jihoo', 'score': 13, 'imgNum': 2},
      ];
    } else if (tabName == '주간') { // 주간 랭킹 데이터
      return [
        {'rank': 1, 'name': 'Yujin', 'score': 27, 'imgNum': 2},
        {'rank': 2, 'name': 'Juyeon', 'score': 25, 'imgNum': 1},
        {'rank': 3, 'name': 'Hajin', 'score': 22, 'imgNum': 3},
        {'rank': 4, 'name': 'jihoo', 'score': 21, 'imgNum': 2},
      ];
    } else { // 월간 랭킹 데이터
      return [
        {'rank': 1, 'name': 'jihoo', 'score': 37, 'imgNum': 2},
        {'rank': 2, 'name': 'Juyeon', 'score': 35, 'imgNum': 1},
        {'rank': 3, 'name': 'Yujin', 'score': 33, 'imgNum': 2},
        {'rank': 4, 'name': 'Hajin', 'score': 30, 'imgNum': 3},
      ];
    }
  }

  // 랭킹 콘텐츠를 생성하는 위젯 (탭에 따른 데이터 사용)
  Widget buildRankingContent(String tabName) {
    List<Map<String, dynamic>> rankingData = getRankingData(tabName); // 해당 탭의 랭킹 데이터 가져오기

    return SingleChildScrollView(  // 전체 화면이 넘치지 않도록 SingleChildScrollView로 감싸기
      child: Column(
        children: [
          SizedBox(height: 16), // 간격 추가
          // 상위 랭커들을 가로로 스크롤 가능하게 만들기
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 가로로 스크롤
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildHighRanker(
                  rankingData[1]['rank'],
                  rankingData[1]['name'],
                  rankingData[1]['imgNum'], // 이미지 경로 전달
                  rankingData[1]['score'],
                  tabName,
                ),
                SizedBox(width: 20),
                buildHighRanker(
                  rankingData[0]['rank'],
                  rankingData[0]['name'],
                  rankingData[0]['imgNum'], // 이미지 경로 전달
                  rankingData[0]['score'],
                  tabName,
                ),
                SizedBox(width: 20),
                buildHighRanker(
                  rankingData[2]['rank'],
                  rankingData[2]['name'],
                  rankingData[2]['imgNum'], // 이미지 경로 전달
                  rankingData[2]['score'],
                  tabName,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // 랭킹 리스트가 화면을 넘지 않도록 Expanded로 감싸기
          Expanded(
            child: ListView.builder(
              shrinkWrap: true, // 리스트뷰가 화면을 초과하지 않도록 하기 위해 shrinkWrap 설정
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
    );
  }

  // 상위 랭커 빌드 함수 (이미지 및 정보 표시)
  Widget buildHighRanker(int rank, String name, int imgNum, int score, String tabName) {
    double avatarRadius = 30; // 프로필 사진 원형 크기
    double textSize = 20; // 텍스트 크기
    Color bgColor = yellowColor;
    double imageSize;
    String assetPath; // 캐릭터 이미지

    // 랭크에 따른 이미지 크기 조정
    if (rank == 1) {
      imageSize = 170;
    } else if (rank == 2) {
      imageSize = 120;
    } else {
      imageSize = 100;
    }

    // 사용자 별 캐릭터 이미지 설정
    if (imgNum == 1) {
      assetPath = 'assets/image/learnerBear.png';
    } else if (imgNum == 2) {
      assetPath = 'assets/image/learnerBrown.png';
    } else {
      assetPath = 'assets/image/learnerRabbit.png';
    }

    return Column(
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
        Image.asset(assetPath, height: imageSize, width: imageSize), // 이미지 표시
        SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // 이름 표시
        SizedBox(height: 4),
        Text(score.toString(), style: TextStyle(fontSize: 16)), // 점수 표시
      ],
    );
  }

  // 일반 랭킹 리스트 빌드 함수
  Widget buildRankList(int rank, String name, int score, Color bgColor) {
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
              child: Text(rank.toString(), style: TextStyle(color: Colors.black)), // 순위 표시
            ),
            SizedBox(width: 4),
            Text(name, style: TextStyle(fontSize: 17), textAlign: TextAlign.center), // 이름 표시
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
  Widget buildCurrentUserRankingTile(String name) {
    String selectedTabName = _tabController.index == 0 ? '일일' : (_tabController.index == 1 ? '주간' : '월간');
    List<Map<String, dynamic>> rankingData = getRankingData(selectedTabName);

    // 현재 사용자의 등수 찾기
    Map<String, dynamic>? currentUserData = rankingData.firstWhere(
          (user) => user['name'] == name,
      orElse: () => {'rank': '-', 'name': '-', 'score': 0, 'imgNum':1},
    );

    return InkWell(
        onTap: () {
          // 클릭 시 새로운 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MakingImage(
                rank: currentUserData?['rank'],
                score: currentUserData?['score'] ,
                name: name,
                imgNum: currentUserData?['imgNum'],
                tabName: getCurrentTabName()
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
            '${currentUserData?['rank']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${currentUserData?['name']}',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            '${currentUserData?['score']}',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
    );
  }

  // 현재 탭의 이름 반환
  String getCurrentTabName() {
    return tabNames[_tabController.index]; // Get tab name by index
  }

}