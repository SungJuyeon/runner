class RankData {
  final int rank;
  final String name;
  final int score;
  final int imgNum;

  RankData({required this.rank, required this.name, required this.score, required this.imgNum});

  factory RankData.fromJson(Map<String, dynamic> json) {
    return RankData(
      rank: json['rank'],
      name: json['name'],
      score: json['score'],
      imgNum: json['imgNum'],
    );
  }
}
