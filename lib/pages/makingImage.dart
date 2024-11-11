import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final Color yellowColor = Color(0xFFEEEB96);
final Color blueColor = Color(0xFF66A2FD);

class MakingImage extends StatefulWidget {
  final int rank;
  final int score;
  final String name;
  final int imgNum;
  final String tabName;

  const MakingImage({
    required this.rank,
    required this.score,
    required this.name,
    required this.imgNum,
    required this.tabName,
  });

  @override
  _MakingImageState createState() => _MakingImageState();
}

class _MakingImageState extends State<MakingImage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _captureAndSaveImage() async {
    try {
      RenderRepaintBoundary boundary =
      _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // 고해상도 캡처

      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 이미지 파일 저장
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ranking_image.png';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지가 저장되었습니다: $filePath')),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 사용자 캐릭터 이미지 경로 설정
    String assetPath;
    if (widget.imgNum == 1) {
      assetPath = 'assets/image/learnerBear.png';
    } else if (widget.imgNum == 2) {
      assetPath = 'assets/image/learnerBrown.png';
    } else {
      assetPath = 'assets/image/learnerRabbit.png';
    }

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/rankingImageBG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // AppBar와 body 내용
          Column(
            children: [
              // AppBar 부분
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 닫기 버튼
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // 본문 내용
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: yellowColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${widget.rank}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '${widget.score} 점',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 29,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Image.asset(
                              assetPath,
                              width: 210,
                              height: 360,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '현재 ${widget.name}님의 ${widget.tabName} 랭킹',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _captureAndSaveImage,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(250, 60),
                          backgroundColor: yellowColor,
                          foregroundColor: Colors.black87,
                        ),
                        child: Text(
                          '인스타에 공유하기',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
