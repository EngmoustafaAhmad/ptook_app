import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/search_competitions/presentation/widgets/competition_card.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:shimmer/shimmer.dart';

class CompetitionSearchView extends StatefulWidget {
  final bool showBackButton;

  const CompetitionSearchView({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<CompetitionSearchView> createState() => _CompetitionSearchViewState();
}

class _CompetitionSearchViewState extends State<CompetitionSearchView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _selectedFilterIndex = 0;
  final Map<String, CompetitionEntity> _localOverrides = {};
  final List<String> _filters = ['All', 'Joined', 'My Created'];

  DateTime? _lastScrollCheck;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetScroll() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _onSearchChanged(String value) {
    _resetScroll();
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final cubit = context.read<SearchCompetitionCubit>();
      if (value.trim().isEmpty) {
        cubit.clearSearch();
      } else {
        cubit.search(value);
      }
    });
  }

  void _onFilterSelected(int index) {
    if (_selectedFilterIndex == index) return;

    setState(() {
      _selectedFilterIndex = index;
    });

    _resetScroll();
    context.read<SearchCompetitionCubit>().changeTab(
          CompetitionTab.values[index],
          query: _controller.text,
        );
  }

  void _onScroll() {
    final now = DateTime.now();
    if (_lastScrollCheck != null &&
        now.difference(_lastScrollCheck!) < const Duration(milliseconds: 150)) {
      return;
    }
    _lastScrollCheck = now;

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

  Future<void> _onRefresh() async {
    setState(() {
      _localOverrides.clear();
    });

    context.read<SearchCompetitionCubit>().changeTab(
          CompetitionTab.values[_selectedFilterIndex],
          query: _controller.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final canGoBack = widget.showBackButton || Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.vs,
              Row(
                children: [
                  if (canGoBack) ...[
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    12.hs,
                  ],
                  const Text(
                    "Search Competitions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              14.vs,
              _buildSearchTextField(),
              16.vs,
              _buildFilterChips(),
              18.vs,
              Expanded(
                child: BlocBuilder<SearchCompetitionCubit,
                    SearchCompetitionState>(
                  builder: (context, state) {
                    if (state is SearchCompetitionLoading) {
                      return _buildShimmerLoader();
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
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          backgroundColor: const Color(0xFF14161D),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Text(
                                    "No competitions found",
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: .5),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final int itemCount = state.competitions.length +
                          (state.isLoadingMore || state.hasReachedMax ? 1 : 0);

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFF14161D),
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: itemCount,
                          separatorBuilder: (_, __) => 12.vs,
                          itemBuilder: (context, index) {
                            if (index == state.competitions.length) {
                              if (state.isLoadingMore) {
                                return const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                );
                              }
                              if (state.hasReachedMax &&
                                  state.competitions.length > 5) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Center(
                                    child: Text(
                                      "No more competitions",
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: .3),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final baseCompetition = state.competitions[index];
                            final competition =
                                _localOverrides[baseCompetition.id] ??
                                    baseCompetition;

                            return CompetitionCard(
                              key: ValueKey(competition.id),
                              competition: competition,
                              currentUserId: currentUserId ?? '',
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
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF14161D),
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: ListView.separated(
        itemCount: 5,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, _) => 12.vs,
        itemBuilder: (_, _) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF14161D),
            borderRadius: BorderRadius.circular(16),
          ),
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
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          return TextField(
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
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () {
                        _controller.clear();
                        _resetScroll();
                        context.read<SearchCompetitionCubit>().clearSearch();
                      },
                    )
                  : null,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: InputBorder.none,
            ),
          );
        },
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
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