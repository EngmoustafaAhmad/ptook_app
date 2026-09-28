import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_state.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/search_competitions/presentation/pages/search_competition_page.dart';
import 'package:ptook/features/search_competitions/presentation/widgets/competition_card.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final SearchCompetitionCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = sl<SearchCompetitionCubit>()..fetchCompetitions();
  }

  @override
  void dispose() {
    _searchCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context) async {
    final user = (context.read<ProfileCubit>().state is ProfileLoaded)
        ? (context.read<ProfileCubit>().state as ProfileLoaded).user
        : null;

    if (user != null) {
      context.read<ProfileCubit>().loadUserProfile(user.id);
      context
          .read<CompetitionHomeCubit>()
          .fetchSavedCompetitions(userId: user.id);
    }
    await _searchCubit.fetchCompetitions(forceRefresh: true);
  }

  int _getJoinedCount(UserEntity? user) {
    if (user == null) return 0;
    int count = user.joinedCompetitionsCount;
    final searchState = _searchCubit.state;
    if (count == 0 && searchState is SearchCompetitionSuccess) {
      count = searchState.competitions
          .where((c) => c.ownerId == user.id || c.isJoinedBy(user.id))
          .length;
    }
    return count;
  }

  int _getSavedCount(UserEntity? user, BuildContext context) {
    if (user == null) return 0;
    int count = user.savedCompetitionsCount;
    final favState = context.watch<CompetitionHomeCubit>().state;
    if (count == 0 && favState is SavedCompetitionsLoaded) {
      count = favState.competitions.length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            if (profileState is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );
            }

            if (profileState is ProfileError) {
              return Center(
                child: Text(
                  profileState.message,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            final user =
                (profileState is ProfileLoaded) ? profileState.user : null;

            return RefreshIndicator(
              color: Colors.amber,
              backgroundColor: AppColors.surface,
              onRefresh: () => _onRefresh(context),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1️⃣ Dynamic Profile Header Card (Live User Data)
                    _buildProfileHeaderCard(user),
                    16.vs,

                    // 2️⃣ Quick Stats Bar (Live Calculated Metrics)
                    _buildQuickStatsBar(user, context),
                    24.vs,

                    // 3️⃣ Search & Filter Trigger Bar
                    _buildSearchBar(context),
                    24.vs,

                    // 4️⃣ Joined Competitions Header
                    _buildSectionTitle(
                      "My Competitions",
                      onSeeAllTap: () => _navigateToSearch(context),
                    ),
                    12.vs,

                    // 5️⃣ Live Joined Competitions List
                    _buildUserCompetitionsList(user),
                    16.vs,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- DYNAMIC PROFILE HEADER CARD ---
  Widget _buildProfileHeaderCard(UserEntity? user) {
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Dynamic User Avatar / Initials
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white10,
              backgroundImage: hasAvatar
                  ? CachedNetworkImageProvider(user!.avatarUrl!)
                  : null,
              child: !hasAvatar
                  ? Text(
                      user?.initials ?? '?',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
          14.hs,

          // Dynamic Name & Handle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Hi, ${user?.name ?? 'User'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    6.hs,
                    const Text("👋", style: TextStyle(fontSize: 16)),
                  ],
                ),
                4.vs,
                Text(
                  user?.handle ?? "@user",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Dynamic Power Units Badge ⚡
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: Colors.amber, size: 22),
                  const SizedBox(width: 2),
                  Text(
                    "${user?.totalPower ?? 0}",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              2.vs,
              Text(
                "Power Units",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DYNAMIC QUICK STATS BAR ---
  Widget _buildQuickStatsBar(UserEntity? user, BuildContext context) {
    final liveJoinedCount = _getJoinedCount(user);
    final liveSavedCount = _getSavedCount(user, context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.emoji_events_outlined,
            "$liveJoinedCount",
            "COMPETITIONS",
          ),
          _buildStatItem(
            Icons.bookmark_border_rounded,
            "$liveSavedCount",
            "SAVED",
          ),
          _buildStatItem(
            Icons.bolt_rounded,
            "${user?.totalPower ?? 0}",
            "POWER ⚡",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 22),
        6.vs,
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        4.vs,
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // --- SECTION TITLE HELPER ---
  Widget _buildSectionTitle(String title,
      {required VoidCallback onSeeAllTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: const Text(
            "View all",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // --- SEARCH BAR TRIGGER ---
  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSearch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            12.hs,
            Text(
              "Search for a competition...",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.filter_list,
              color: Colors.amber,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // --- LIVE JOINED COMPETITIONS FEED ---
  Widget _buildUserCompetitionsList(UserEntity? user) {
    if (user == null) return _buildCompetitionsPlaceholder();

    return BlocProvider.value(
      value: _searchCubit,
      child: BlocBuilder<SearchCompetitionCubit, SearchCompetitionState>(
        builder: (context, state) {
          if (state is SearchCompetitionLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          }

          if (state is SearchCompetitionSuccess) {
            final myCompetitions = state.competitions.where((comp) {
              return comp.ownerId == user.id || comp.isJoinedBy(user.id);
            }).toList();

            if (myCompetitions.isEmpty) {
              return _buildCompetitionsPlaceholder();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myCompetitions.length,
              separatorBuilder: (_, __) => 12.vs,
              itemBuilder: (context, index) {
                return CompetitionCard(
                  competition: myCompetitions[index],
                  currentUserId: user.id,
                );
              },
            );
          }

          return _buildCompetitionsPlaceholder();
        },
      ),
    );
  }

  // --- COMPETITIONS PLACEHOLDER ---
  Widget _buildCompetitionsPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            color: Colors.white38,
            size: 48,
          ),
          12.vs,
          const Text(
            "No Active Competitions Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          6.vs,
          Text(
            "Create or join a competition to start competing!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVIGATION WITH BACK BUTTON ---
  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<SearchCompetitionCubit>(),
          child: const CompetitionSearchView(showBackButton: true),
        ),
      ),
    );
  }
}