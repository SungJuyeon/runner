import 'package:flutter/material.dart';
import 'package:runner/pages/makingImage.dart';

class ranking_page extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<ranking_page> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 색상 정의
  final Color yellowColor = Color(0xFFEEEB96);
  final Color blueColor = Color(0xFF66A2FD);
  // 탭 이름 배열
  final List<String> tabNames = ['일일', '주간', '월간'];


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
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'BMDOHYEON_ttf'),
      ),
      child: Scaffold(
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildRankingContent(),
                  buildRankingContent(),
                  buildRankingContent(),
                ],
              ),
            ),
            buildCurrentUserRankingTile(1, 'Juyean', 17),
          ],
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
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


  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.star), // 랭킹 아이콘
          label: '랭킹',
        ),
        BottomNavigationBarItem(
          icon: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF66A2FD),
            ),
            child: Icon(Icons.home, color: Colors.white), // 홈 아이콘
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person), // 마이 아이콘
          label: '마이',
        ),
      ],
      currentIndex: 1, // 홈 버튼이 현재 선택된 상태로 표시
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      iconSize: 20,
      onTap: (index) {
        // 버튼 클릭 시의 동작 처리
        setState(() {
          // 선택된 인덱스에 따라 화면 전환 로직을 추가할 수 있습니다.
        });
      },
    );
  }

  // 현재 사용자 등수 타일
  Widget buildCurrentUserRankingTile(int rank, String name, int score) {
    return InkWell(
        onTap: () {
      // 클릭 시 새로운 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MakingImage(
            rank: rank,
            name: name,
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
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
    ),
    );
  }

  // 현재 탭의 이름 반환
  String getCurrentTabName() {
    return tabNames[_tabController.index]; // Get tab name by index
  }

}
