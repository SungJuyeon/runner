import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle을 위해 필요
import 'package:path_provider/path_provider.dart'; // 임시 디렉토리에 파일 저장
import 'package:share_plus/share_plus.dart'; // 파일 공유를 위해 사용

final Color yellowColor = Color(0xFFEEEB96);
final Color blueColor = Color(0xFF66A2FD);

class MakingImage extends StatelessWidget {
  final int rank;
  final String name;
  final int imgNum;
  final String tabName;

  const MakingImage({required this.rank, required this.name, required this.imgNum, required this.tabName});

  @override
  Widget build(BuildContext context) {
    String assetPath;
    if (imgNum == 1) {
      assetPath = 'assets/image/learnerBear.png';
    } else if (imgNum == 2) {
      assetPath = 'assets/image/learnerBrown.png';
    } else {
      assetPath = 'assets/image/learnerRabbit.png';
    }

    return Scaffold(
      backgroundColor: blueColor,
      appBar: AppBar(
        backgroundColor: blueColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: EdgeInsets.all(0),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '현재 $name님의 $tabName 랭킹',
              style: TextStyle(color: Colors.black87, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: yellowColor,
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Image.asset(
              assetPath,
              width: 180,
              height: 260,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                shareToInstagram(assetPath);
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
    );
  }

  Future<void> shareToInstagram(String assetPath) async {
    try {
      // assets 폴더에 있는 이미지를 메모리로 로드
      final byteData = await rootBundle.load(assetPath);
      // 임시 디렉토리에 파일 저장
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_image.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share 패키지를 통해 Instagram으로 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '현재 $name님의 $tabName 랭킹은 $rank위입니다!',
      );
    } catch (e) {
      print("Error sharing image: $e");
    }
  }
}
