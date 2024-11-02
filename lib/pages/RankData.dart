class RankData {
  final int rank;
  final String name;
  final int score;
  final String imageUrl;

  RankData({required this.rank, required this.name, required this.score, required this.imageUrl});

  factory RankData.fromJson(Map<String, dynamic> json) {
    return RankData(
      rank: json['rank'],
      name: json['name'],
      score: json['score'],
      imageUrl: json['imageUrl'],
    );
  }
}
