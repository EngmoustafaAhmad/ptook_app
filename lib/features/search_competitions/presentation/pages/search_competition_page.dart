import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/search_competitions/presentation/widgets/competition_card.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_details_view.dart' hide AppColors;

class CompetitionSearchView extends StatefulWidget {
  const CompetitionSearchView({super.key});

  @override
  State<CompetitionSearchView> createState() => _CompetitionSearchViewState();
}

class _CompetitionSearchViewState extends State<CompetitionSearchView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;
  int _selectedFilterIndex = 0;

  final List<String> _filters = ['All', 'Joined', 'My Created'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCompetitions();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Reset scroll position to top when changing filters/search
  void _resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  /// Handles empty search vs query search
  Future<void> _fetchCompetitions() async {
    _resetScroll();
    final cubit = context.read<SearchCompetitionCubit>();
    final trimmedQuery = _controller.text.trim();
    final String? searchQuery = trimmedQuery.isEmpty ? null : trimmedQuery;

    if (searchQuery == null) {
      switch (_selectedFilterIndex) {
        case 0:
          cubit.getPublicCompetitions();
          break;
        case 1:
          cubit.getJoinedCompetitions();
          break;
        case 2:
          cubit.getCreatedCompetitions();
          break;
      }
    } else {
      switch (_selectedFilterIndex) {
        case 0:
          cubit.search(searchQuery);
          break;
        case 1:
          cubit.getJoinedCompetitions(query: searchQuery);
          break;
        case 2:
          cubit.getCreatedCompetitions(query: searchQuery);
          break;
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCompetitions();
    });
    setState(() {}); 
  }

  void _onFilterSelected(int index) {
    if (_selectedFilterIndex == index) return;

    setState(() {
      _selectedFilterIndex = index;
    });

    _fetchCompetitions();
  }

  /// Guard against triggering multiple loadMore calls
  void _onScroll() {
    if (_isBottom) {
      final state = context.read<SearchCompetitionCubit>().state;
      if (state is SearchCompetitionSuccess &&
          !state.isLoadingMore &&
          !state.hasReachedMax) {
        context.read<SearchCompetitionCubit>().loadMore();
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _navigateToDetails(
    BuildContext context,
    CompetitionEntity competition,
  ) async {
    final updatedCompetition = await Navigator.push<CompetitionEntity?>(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailsView(
          competition: competition,
        ),
      ),
    );

    if (!context.mounted) return;

    if (updatedCompetition != null) {
      context
          .read<SearchCompetitionCubit>()
          .updateCompetitionInList(updatedCompetition);
    } else {
      _fetchCompetitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            12.vs,
            const Text(
              "Search Competitions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            14.vs,
            _buildSearchTextField(),
            16.vs,
            _buildFilterChips(),
            18.vs,
            Expanded(
              child: BlocBuilder<SearchCompetitionCubit, SearchCompetitionState>(
                builder: (context, state) {
                  if (state is SearchCompetitionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is SearchCompetitionError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  if (state is SearchCompetitionSuccess) {
                    if (state.competitions.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _fetchCompetitions,
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFF14161D),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Text(
                                  "No competitions found",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .5),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Total items count includes footer loader or end-of-list indicator
                    final int itemCount = state.competitions.length +
                        (state.isLoadingMore || state.hasReachedMax ? 1 : 0);

                    return RefreshIndicator(
                      onRefresh: _fetchCompetitions,
                      color: AppColors.primary,
                      backgroundColor: const Color(0xFF14161D),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: itemCount,
                        separatorBuilder: (_, _) => 12.vs,
                        itemBuilder: (context, index) {
                          // Handle Bottom Footer (Loader OR Reached Max Indicator)
                          if (index == state.competitions.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              );
                            }
                            if (state.hasReachedMax && state.competitions.length > 5) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: Text(
                                    "No more competitions",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .3),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final competition = state.competitions[index];
                          final isOwner = currentUserId != null &&
                              currentUserId == competition.ownerId;
                          final isJoined =
                              competition.isJoinedBy(currentUserId);

                          return GestureDetector(
                            onTap: () => _navigateToDetails(
                              context,
                              competition,
                            ),
                            child: CompetitionCard(
                              key: ValueKey(competition.id),
                              competition: competition,
                              isOwner: isOwner,
                              isJoined: isJoined,
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTextField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: .06),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search tournaments, leagues...",
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: .4),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.white54,
            size: 22,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 20),
                  onPressed: () {
                    _debounce?.cancel();
                    _controller.clear();
                    setState(() {});
                    _fetchCompetitions();
                  },
                )
              : null,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => _onFilterSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF14161D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white60,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}