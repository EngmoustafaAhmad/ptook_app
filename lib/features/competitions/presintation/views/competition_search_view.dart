import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/views/competition_details_view.dart';
import 'package:ptook/features/competitions/presintation/views/create_competition_view.dart';
import 'package:ptook/features/competitions/presintation/widgets/competition_card.dart';

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

    // Initial fetch when screen opens
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

  /// Handles empty search vs query search
  Future<void> _fetchCompetitions() async {
    final cubit = context.read<SearchCompetitionCubit>();
    final trimmedQuery = _controller.text.trim();
    final String? searchQuery = trimmedQuery.isEmpty ? null : trimmedQuery;

    // 1. SEARCHBAR IS EMPTY
    if (searchQuery == null) {
      switch (_selectedFilterIndex) {
        case 0: // All / Public
          cubit.getPublicCompetitions();
          break;
        case 1: // Joined
          cubit.getJoinedCompetitions();
          break;
        case 2: // My Created
          cubit.getCreatedCompetitions();
          break;
      }
    } 
    // 2. SEARCHBAR HAS TEXT
    else {
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

  /// Debounces user input to avoid making backend requests on every single keystroke
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCompetitions();
    });
    setState(() {}); // Updates clear icon visibility
  }

  void _onFilterSelected(int index) {
    if (_selectedFilterIndex == index) return;

    setState(() {
      _selectedFilterIndex = index;
    });

    _fetchCompetitions();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchCompetitionCubit>().loadMore();
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
      // Re-fetch list if item was deleted or state needs full sync
      _fetchCompetitions();
    }
  }

  Future<void> _navigateToCreateCompetition() async {
    final isCreated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateCompetitionView(),
      ),
    );

    if (isCreated == true && context.mounted) {
      _fetchCompetitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildCustomAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _navigateToCreateCompetition,
        child: const Icon(Icons.add, color: Colors.black),
      ),
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

            // Search Bar Input Field
            _buildSearchTextField(),
            16.vs,

            // Filter Chips Bar
            _buildFilterChips(),
            18.vs,

            // Feed Results
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
                                    color: Colors.white.withOpacity(.5),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _fetchCompetitions,
                      color: AppColors.primary,
                      backgroundColor: const Color(0xFF14161D),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: state.competitions.length +
                            (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => 12.vs,
                        itemBuilder: (context, index) {
                          if (index == state.competitions.length) {
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

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 26),
        onPressed: () {},
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 6),
          Text(
            "PTOOK",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primary, size: 26),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchTextField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Search tournaments, leagues...",
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
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
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                          color: AppColors.primary.withOpacity(0.2),
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