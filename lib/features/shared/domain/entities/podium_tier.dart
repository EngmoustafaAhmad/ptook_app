enum PodiumTier {
  gold(3),
  silver(2),
  bronze(1),
  none(0);

  final int stars;
  const PodiumTier(this.stars);

  static PodiumTier fromPosition(int rank) {
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