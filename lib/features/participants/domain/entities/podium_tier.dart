enum PodiumTier {
  gold(stars: 3, rank: 1),
  bronze(stars: 2, rank: 3),
  silver(stars: 1, rank: 2),
  none(stars: 0, rank: 0);

  final int stars;
  final int rank;

  const PodiumTier({required this.stars, required this.rank});

  /// Helper to convert numeric rank (1, 2, 3) to PodiumTier
  factory PodiumTier.fromRank(int rank) {
    switch (rank) {
      case 1:
        return PodiumTier.gold;
      case 2:
        return PodiumTier.silver;
      case 3:
        return PodiumTier.bronze;
      default:
        return PodiumTier.none;
    }
  }
}