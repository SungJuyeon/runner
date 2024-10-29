import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final int totalLevels = 3; //level 수
  late List<bool> isLocked; //level 잠금

  @override
  void initState() {  //초기 level 상태
    super.initState();
    //level 2 부터 잠금
    isLocked = List.generate(totalLevels, (index) => index > 0);
  }

  void unlockLevel(int level) {  //잠금 해제
    setState(() {   //상태 변경 시 UI 갱신
      if (level - 1 < totalLevels) {  //유효한 level 인지 확인
        isLocked[level - 1] = false;  //해당 level 잠금 해제
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),  //level 사각형 상하 여백
          children: List.generate(totalLevels, (index) {
            final levelNumber = index + 1; //현재 level
            return Column(
              children: [
                Align(  //정렬
                  alignment: Alignment.center,  //화면의 가운데 정렬
                  child: buildLevelContainer('level $levelNumber', isLocked: isLocked[index]), //레벨 컨테이너 생성
                ),
                const SizedBox(height: 20), // 레벨 간의 간격
              ],
            );
          }),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     unlockLevel(2); // 레벨 2 잠금 해제
        //   },
        //   child: const Icon(Icons.lock_open), // 잠금 해제 아이콘
        //),
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.leaderboard),
                      Text('랭킹'),
                    ],
                  ),
                  const SizedBox(width: 48), // 홈 버튼 공간 확보
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person),
                      Text('마이'),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 15, // 홈 버튼 원 위치 조정
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
                        style: TextStyle(color: Colors.white, fontSize: 15,)
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      theme: ThemeData(fontFamily: 'dohyeon'),
      themeMode: ThemeMode.system,
    );
  }

  Widget buildLevelContainer(String levelText, {bool isLocked = false}) {
    return isLocked // 레벨이 잠겨있다면
        ? notYetLevel(levelText) // 잠금 레벨 표시
        : Container( // 레벨이 잠겨있지 않다면
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF66A2FD), // 배경 색상
        borderRadius: BorderRadius.circular(30),  // 둥근 모서리
        boxShadow: [  // 그림자 효과
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF66A2FD), //level 써있는 버튼 색상
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            height: 65,
            child: Center(
              child: Text(
                levelText,  // 레벨 텍스트
                style: const TextStyle(
                  color: Color(0xFFF0EC7D),
                  fontSize: 23,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 5),
                      blurRadius: 4.0,
                      color: Color.fromARGB(128, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 1.5,  // 구분선 높이
            color: Colors.white,  // 구분선 색상
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF66A2FD),  // "문제 풀기" 버튼 색상
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '문제\n풀기',
                        style: TextStyle(
                          color: Color(0xFFF0EC7D), // 텍스트 색상
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 3),
                              blurRadius: 4.0,
                              color: Color.fromARGB(128, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2, // 구분선 너비
                  color: Colors.white,  // 구분선 색상
                  //color: const Color(0xFFF0EC7D),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF66A2FD), //"단어 보기" 버튼 색상
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '단어\n보기',
                        style: TextStyle(
                          color: Color(0xFFF0EC7D),
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 3),
                              blurRadius: 4.0,
                              color: Color.fromARGB(128, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget notYetLevel(String levelText) {   // 잠긴 레벨 표시 위젯
    return Stack( // 스택으로 겹쳐서 표시
      children: [
        Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF66A2FD),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [  //그림자
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF66A2FD),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                height: 65,
                child: Center(
                  child: Text(
                    levelText,
                    style: const TextStyle(
                      color: Color(0xFFF0EC7D),
                      fontSize: 23,
                    ),
                  ),
                ),
              ),
              Container(
                height: 1.5,
                color: Colors.white,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF66A2FD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '문제\n풀기',
                            style: TextStyle(
                              color: Color(0xFFF0EC7D),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF66A2FD),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '단어\n보기',
                            style: TextStyle(
                              color: Color(0xFFF0EC7D),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xBB3C3F43), // 80%투명도로 덮기
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Icon(
              Icons.lock,
              color: Colors.black54,
              size: 40,
            ),
          ),
        ),
      ],
    );
  }

}