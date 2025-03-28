class RatingStats {
  final double averageRating;
  final int totalReviews;
  final int totalStudents;
  final List<Map<String, dynamic>> ratingDistribution;

  RatingStats({
    required this.averageRating,
    required this.totalReviews,
    required this.totalStudents,
    required this.ratingDistribution,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      averageRating: json['averageRating'].toDouble(),
      totalReviews: json['totalReviews'],
      totalStudents: json['totalStudents'],
      ratingDistribution: List<Map<String, dynamic>>.from(
        json['ratingDistribution'].map((x) => {
              'stars': x['stars'],
              'count': x['count'],
              'percentage': x['percentage'].toDouble(),
            }),
      ),
    );
  }
}
