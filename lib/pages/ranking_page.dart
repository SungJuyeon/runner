import 'package:flutter/material.dart';
import 'navigationBar.dart';

class ranking_page extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<ranking_page> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 색상 정의
  final Color yellowColor = Color(0xFFEEEB96);
  final Color blueColor = Color(0xFF66A2FD);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('랭킹', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: blueColor,
          tabs: [
            Tab(text: '일일'),
            Tab(text: '주간'),
            Tab(text: '월간'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 탭 뷰와 랭킹 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildRankingContent(), // 일일 랭킹 콘텐츠
                buildRankingContent(), // 주간 랭킹 콘텐츠
                buildRankingContent(), // 월간 랭킹 콘텐츠
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0), // 위로 5픽셀 올리기
            child: buildCurrentUserRankingTile(1, 'Juyean', 17),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context), // BottomNavigationBar 네비게이션 바

    );

  }


  // 상위랭커, 일반 랭크 둘다 내용 채우기
  Widget buildRankingContent() {
    return Stack( // Stack으로 변경
      children: [
        Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildHighRanker(2, 'Yujin', 'assets/image/learnerBear.png', 15, yellowColor),
                SizedBox(width: 20),//간격
                buildHighRanker(1, 'Juyeon', 'assets/image/learnerBrown.png', 17, yellowColor),
                SizedBox(width: 20),//간격
                buildHighRanker(3, 'Hajin', 'assets/image/learnerRabbit.png', 14, yellowColor),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildRankList(1, 'Juyeon', 17, yellowColor),
                  buildRankList(2, 'Yujin', 15, yellowColor),
                  buildRankList(3, 'Hajin', 14, yellowColor),
                  buildRankList(4, 'Jihoo', 13, yellowColor),
                  // 추가 랭킹 항목을 여기에 추가
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildHighRanker(int rank, String name, String assetPath, int score, Color bgColor) {
    // rank에 따라 크기 설정
    double avatarRadius = 30; // 모든 순위의 원 크기
    double textSize = 20; // 모든 순위의 텍스트 크기
    double imageSize;
    // 이미지 크기를 rank에 따라 설정
    if (rank == 1) {
      imageSize = 130; // 1등의 이미지 크기
    } else if (rank == 2) {
      imageSize = 110; // 2등의 이미지 크기
    } else {
      imageSize = 90; // 3등의 이미지 크기
    }

    return Column(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: bgColor,
          child: Center(
            child: Text(
              rank.toString(), // 순위를 원 안에 표시
              style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 8),
        // 아바타 이미지가 순위 아래에 표시되도록 변경
        Image.asset(assetPath, height: imageSize, width: imageSize), // 1등의 이미지만 크게 설정
        SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(score.toString(), style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // 전체 랭킹 출력
  Widget buildRankList(int rank, String name, int score, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: yellowColor, // 노란색 배경
        borderRadius: BorderRadius.circular(10), // 둥근 모서리 설정
      ),
      margin: EdgeInsets.symmetric(vertical: 7), // 각 타일 간의 여백
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), // 내부 여백
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // 요소들을 간격을 두고 정렬
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Text(rank.toString(), style: TextStyle(color: Colors.black)),
            ),
            SizedBox(width: 4), // 간격 조정
            Text(
              name,
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center, // 이름 텍스트 가운데 정렬
            ),
            SizedBox(width: 4), // 간격 조정
            Text(score.toString(), style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
    );
  }


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

  // 현재 사용자 등수 타일
  Widget buildCurrentUserRankingTile(int rank, String name, int score) {
    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$rank',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 18),
          ),
          Text(
            score.toString(),
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

}
