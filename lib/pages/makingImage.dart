import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // rootBundle을 위해 필요
import 'package:path_provider/path_provider.dart'; // 임시 디렉토리에 파일 저장
import 'package:share_plus/share_plus.dart'; // 파일 공유를 위해 사용

import 'package:flutter/services.dart'; // rootBundle을 위해 필요
import 'package:share_plus/share_plus.dart'; // 파일 공유를 위해 사용

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


  Future<void> shareToInstagram(String filePath) async {
    try {
      final imageFile = File(filePath);

      // 파일이 존재하는지 확인
      if (await imageFile.exists()) {
        // Share 패키지를 통해 Instagram으로 공유
        await Share.shareXFiles(
          [XFile(imageFile.path)],  // File 경로를 전달
          text: '현재 ${widget.name}님의 ${widget.tabName} 랭킹은 ${widget.rank}위입니다!',
        );
        print("Image shared successfully.");
      } else {
        print("Image file does not exist at $filePath");
      }
    } catch (e) {
      print("Error sharing image: $e");
    }
  }


  Future<void> _captureAndSaveImage() async {
    try {
      // RepaintBoundary를 감싸는 전체 영역을 캡처
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

      // 파일이 존재하는지 확인
      if (await imageFile.exists()) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('이미지가 저장되었습니다: $filePath')),
        // );

        // 저장된 이미지를 인스타그램 등으로 공유
        await shareToInstagram(filePath);
      }
    } catch (e) {
      print("Error during image capture and save: $e");
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
          // 배경 이미지를 RepaintBoundary 안으로 이동
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/rankingImageBG.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // AppBar 부분
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(top: MediaQuery
                        .of(context)
                        .padding
                        .top),
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
                            iconSize: 27,
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
                          SizedBox(height: 7),
                          Text(
                            '${widget.score} 점',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 29,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1),
                          Image.asset(
                            assetPath,
                            width: 210,
                            height: 360,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '현재 ${widget.name}님의 ${widget.tabName} 랭킹',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 버튼을 아래로 올리기
                          SizedBox(height: 10), // 버튼과 텍스트 사이 간격을 조절
                          ElevatedButton(
                            onPressed: () async {
                              // 먼저 이미지를 캡처하고 저장
                              await _captureAndSaveImage();
                              // 저장한 이미지를 Instagram으로 공유
                              //await shareToInstagram(assetPath);
                            },
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
            ),
          ),
        ],
      ),
    );
  }
}