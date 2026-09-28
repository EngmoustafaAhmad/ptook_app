import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_cubit.dart';
import 'package:ptook/features/profile/presintation/cubit/profile/profile_state.dart';
import 'package:ptook/features/profile/presintation/cubit/update_profile/update_profile_cubit.dart';
import 'package:ptook/features/profile/presintation/views/settings_profile_view.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/search_competitions/presentation/widgets/competition_card.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/shared/domain/entities/user_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_state.dart';

class ProfileView extends StatefulWidget {
  final String userId;

  const ProfileView({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedTabIndex = 0;

  // ⚡ AdMob Banner Ad variables
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // 🧪 Official Test Banner Ad Unit ID for Android
  final String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  // Design Token Colors
  static const Color _bgColor = Color(0xFF0D0F14);
  static const Color _cardColor = Color(0xFF141721);
  static const Color _goldColor = Color(0xFFFFB800);
  static const Color _textDim = Color(0xFF8E92A0);
  static const Color _borderDim = Color(0xFF1F2433);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadBannerAd();
  }

  void _loadInitialData() {
    context.read<ProfileCubit>().watchProfile(widget.userId);
    context.read<SearchCompetitionCubit>().search('');
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Profile Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompetitionHomeCubit>(
      create: (context) => sl<CompetitionHomeCubit>()
        ..fetchSavedCompetitions(userId: widget.userId),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: _goldColor),
                );
              }

              if (state is ProfileError) {
                return _buildErrorState(state.message);
              }

              if (state is ProfileLoaded) {
                final user = state.user;

                return RefreshIndicator(
                  color: _goldColor,
                  backgroundColor: _cardColor,
                  onRefresh: () async {
                    _loadInitialData();
                    if (_selectedTabIndex == 0) {
                      context
                          .read<CompetitionHomeCubit>()
                          .fetchSavedCompetitions(userId: widget.userId);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      children: [
                        _buildTopAppBar(context, user),
                        const SizedBox(height: 12),
                        _buildGoldenAvatar(user),
                        const SizedBox(height: 14),
                        _buildIdentitySection(user),
                        const SizedBox(height: 24),
                        _buildStatCards(user),
                        const SizedBox(height: 24),
                        _buildSegmentedTabs(context),
                        const SizedBox(height: 24),
                        _buildSectionHeader(user),
                        const SizedBox(height: 16),
                        _buildReactiveFeed(user),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: _buildBannerAdWidget(),
      ),
    );
  }

  Widget? _buildBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        color: _bgColor,
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  Widget _buildTopAppBar(BuildContext context, UserEntity user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'PROFILE',
          style: TextStyle(
            color: _goldColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        IconButton(
          onPressed: () => _navigateToSettings(context, user),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: _borderDim),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: _goldColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // --- Golden Avatar ---
  Widget _buildGoldenAvatar(UserEntity user) {
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

    final double dpr = MediaQuery.of(context).devicePixelRatio;
    const double avatarLogicalDiameter = 112.0;
    final int physicalCacheDimension = (avatarLogicalDiameter * dpr).round();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Radial Glow Effect
        Container(
          width: 125,
          height: 125,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _goldColor.withOpacity(0.45),
                blurRadius: 35,
                spreadRadius: 6,
              ),
            ],
          ),
        ),

        // Golden Ring Container with User Image/Initials
        Container(
          width: 118,
          height: 118,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_goldColor, Color(0xFF8A6500)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: CircleAvatar(
              backgroundColor: _cardColor,
              backgroundImage: hasAvatar
                  ? CachedNetworkImageProvider(
                      avatarUrl,
                      maxHeight: physicalCacheDimension,
                      maxWidth: physicalCacheDimension,
                    )
                  : null,
              child: !hasAvatar
                  ? Text(
                      user.initials,
                      style: const TextStyle(
                        color: _goldColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentitySection(UserEntity user) {
    return Column(
      children: [
        Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.handle,
          style: const TextStyle(
            color: _textDim,
            fontSize: 14,
          ),
        ),
        if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            user.bio!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  // ⚡ Dynamic Helper Methods for Real-time Counts
  int _getJoinedCount(UserEntity user) {
    int count = user.joinedCompetitionsCount;
    final searchState = context.watch<SearchCompetitionCubit>().state;
    if (count == 0 && searchState is SearchCompetitionSuccess) {
      count = searchState.competitions
          .where((c) => c.ownerId == user.id || c.isJoinedBy(user.id))
          .length;
    }
    return count;
  }

  int _getSavedCount(UserEntity user) {
    int count = user.savedCompetitionsCount;
    final favState = context.watch<CompetitionHomeCubit>().state;
    if (count == 0 && favState is SavedCompetitionsLoaded) {
      count = favState.competitions.length;
    }
    return count;
  }

  Widget _buildStatCards(UserEntity user) {
    final liveJoinedCount = _getJoinedCount(user);
    final liveSavedCount = _getSavedCount(user);

    return Row(
      children: [
        _buildStatCard(
          icon: Icons.bolt_rounded,
          value: '${user.totalPower}',
          label: 'POWER',
          tabIndex: null,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.emoji_events_rounded,
          value: '$liveJoinedCount',
          label: 'JOINED',
          tabIndex: 1,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.bookmark_rounded,
          value: '$liveSavedCount',
          label: 'SAVED',
          tabIndex: 0,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required int? tabIndex,
  }) {
    final bool isSelected = tabIndex != null && _selectedTabIndex == tabIndex;

    return Expanded(
      child: InkWell(
        onTap: tabIndex != null ? () => _onTabChanged(tabIndex) : null,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _goldColor : _borderDim,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _goldColor.withOpacity(0.25),
                      blurRadius: 15,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _goldColor, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  color: isSelected ? _goldColor : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _goldColor : _textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs(BuildContext context) {
    final List<String> tabs = ['Saved', 'Competitions', 'History'];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderDim),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _goldColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index == 0 && isSelected) ...[
                      const Icon(Icons.bookmark,
                          size: 16, color: Colors.black),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : _textDim,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    if (index == 0) {
      context
          .read<CompetitionHomeCubit>()
          .fetchSavedCompetitions(userId: widget.userId);
    }
  }

  Widget _buildSectionHeader(UserEntity user) {
    String label;
    switch (_selectedTabIndex) {
      case 0:
        label = 'BOOKMARKED ARENAS (${_getSavedCount(user)})';
        break;
      case 1:
        label = 'MY COMPETITIONS (${_getJoinedCount(user)})';
        break;
      case 2:
        label = 'PAST HISTORY';
        break;
      default:
        label = '';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textDim,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const Text(
          'Filter',
          style: TextStyle(
            color: _goldColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReactiveFeed(UserEntity user) {
    // ⚡ Tab Index 0: Fetch from CompetitionHomeCubit (Favorite / Saved Competitions)
    if (_selectedTabIndex == 0) {
      return BlocBuilder<CompetitionHomeCubit, CompetitionHomeState>(
        builder: (context, state) {
          if (state is CompetitionHomeLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: _goldColor),
              ),
            );
          }

          if (state is SavedCompetitionsLoaded) {
            final savedList = state.competitions;

            if (savedList.isEmpty) {
              return _buildEmptyFeedState();
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: savedList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return CompetitionCard(
                  competition: savedList[index],
                  currentUserId: widget.userId,
                );
              },
            );
          }

          if (state is CompetitionHomeError) {
            return Center(
              child: Text(
                state.message,
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            );
          }

          return _buildEmptyFeedState();
        },
      );
    }

    // ⚡ Tab Indices 1 & 2: Filter from SearchCompetitionCubit
    return BlocBuilder<SearchCompetitionCubit, SearchCompetitionState>(
      builder: (context, state) {
        if (state is SearchCompetitionLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: _goldColor),
            ),
          );
        }

        if (state is SearchCompetitionSuccess) {
          final List<CompetitionEntity> filteredList = _filterCompetitions(
            competitions: state.competitions,
            user: user,
            tabIndex: _selectedTabIndex,
          );

          if (filteredList.isEmpty) {
            return _buildEmptyFeedState();
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return CompetitionCard(
                competition: filteredList[index],
                currentUserId: widget.userId,
              );
            },
          );
        }

        return _buildEmptyFeedState();
      },
    );
  }

  List<CompetitionEntity> _filterCompetitions({
    required List<CompetitionEntity> competitions,
    required UserEntity user,
    required int tabIndex,
  }) {
    switch (tabIndex) {
      case 1:
        return competitions
            .where((c) => c.ownerId == user.id || c.isJoinedBy(user.id))
            .toList();
      case 2:
        return competitions
            .where((c) =>
                c.isFinished && (c.ownerId == user.id || c.isJoinedBy(user.id)))
            .toList();
      default:
        return [];
    }
  }

  Widget _buildEmptyFeedState() {
    String message;
    switch (_selectedTabIndex) {
      case 0:
        message = 'No bookmarked competitions found.';
        break;
      case 1:
        message = 'You have not joined or created any competitions.';
        break;
      case 2:
        message = 'No competition history available.';
        break;
      default:
        message = 'No data available.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: _textDim,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
            onPressed: _loadInitialData,
            child: const Text('Retry', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context, UserEntity user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<UpdateProfileCubit>(
          create: (context) => sl<UpdateProfileCubit>(),
          child: SettingsProfileView(currentUser: user),
        ),
      ),
    );
  }
}