import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/features/participants/domain/entities/participant_entity.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_cubit.dart';
import 'package:ptook/features/participants/presintation/bloc/participants_state.dart';

enum ParticipantFilter { all, top3, myRank }

class CompetitionParticipantsView extends StatefulWidget {
  final String competitionId;
  final String currentUserId;

  const CompetitionParticipantsView({
    super.key,
    required this.competitionId,
    required this.currentUserId,
  });

  @override
  State<CompetitionParticipantsView> createState() =>
      _CompetitionParticipantsViewState();
}

class _CompetitionParticipantsViewState
    extends State<CompetitionParticipantsView> {
  final TextEditingController _searchController = TextEditingController();
  ParticipantFilter _selectedFilter = ParticipantFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchParticipants() {
    context
        .read<ParticipantCubit>()
        .fetchParticipants(widget.competitionId);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<ParticipantEntity> _getFilteredParticipants(
      List<ParticipantEntity> participants) {
    // 1. Sort participants by points descending to establish ranking
    final sortedList = List<ParticipantEntity>.from(participants)
      ..sort((a, b) => b.points.compareTo(a.points));

    // 2. Filter by search query
    var list = sortedList.where((p) {
      return p.name.toLowerCase().contains(_searchQuery);
    }).toList();

    // 3. Apply tab filters
    switch (_selectedFilter) {
      case ParticipantFilter.top3:
        return list.take(3).toList();
      case ParticipantFilter.myRank:
        return list
            .where((p) => p.userId == widget.currentUserId)
            .toList();
      case ParticipantFilter.all:
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: _buildAppBar(context),
      body: BlocConsumer<ParticipantCubit, ParticipantState>(
        listener: (context, state) {
          if (state is ParticipantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ParticipantLoading &&
              state is! ParticipantActionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9D61FF)),
            );
          }

          List<ParticipantEntity> allParticipants = [];
          if (state is ParticipantLoaded) {
            allParticipants = state.participants;
          }

          final filteredParticipants =
              _getFilteredParticipants(allParticipants);

          return RefreshIndicator(
            color: const Color(0xFF9D61FF),
            backgroundColor: const Color(0xFF1B1E2B),
            onRefresh: () async => _fetchParticipants(),
            child: Column(
              children: [
                // Search Bar & Filter Chips Header
                _ParticipantsHeader(
                  searchController: _searchController,
                  selectedFilter: _selectedFilter,
                  totalCount: allParticipants.length,
                  onFilterSelected: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),

                // Main Participants List / Empty State
                Expanded(
                  child: filteredParticipants.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filteredParticipants.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final participant = filteredParticipants[index];
                            final rank = allParticipants
                                    .indexWhere((p) => p.id == participant.id) +
                                1;
                            final isCurrentUser =
                                participant.userId == widget.currentUserId;

                            return _ParticipantListTile(
                              rank: rank > 0 ? rank : index + 1,
                              participant: participant,
                              isCurrentUser: isCurrentUser,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F111A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'All Participants',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 70,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Participants Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search query or filters',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-COMPONENTS
// =============================================================================

/// Header containing Search input and Filter Chips
class _ParticipantsHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ParticipantFilter selectedFilter;
  final int totalCount;
  final ValueChanged<ParticipantFilter> onFilterSelected;

  const _ParticipantsHeader({
    required this.searchController,
    required this.selectedFilter,
    required this.totalCount,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F111A),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search participant...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1B1E2B),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF9D61FF), width: 1),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips Row
          Row(
            children: [
              _buildFilterChip(
                label: 'All ($totalCount)',
                filter: ParticipantFilter.all,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Top 3',
                filter: ParticipantFilter.top3,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'My Rank',
                filter: ParticipantFilter.myRank,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ParticipantFilter filter,
  }) {
    final isSelected = selectedFilter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      selectedColor: const Color(0xFF9D61FF),
      backgroundColor: const Color(0xFF1B1E2B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF9D61FF) : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}

/// Participant Row Card Component
class _ParticipantListTile extends StatelessWidget {
  final int rank;
  final ParticipantEntity participant;
  final bool isCurrentUser;

  const _ParticipantListTile({
    required this.rank,
    required this.participant,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty;

    // Custom coloring based on Leaderboard placement
    final rankColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.white54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF261843)
            : const Color(0xFF1B1E2B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF9D61FF).withOpacity(0.5)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: rankColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // User Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: hasAvatar ? NetworkImage(participant.avatarUrl!) : null,
            child: !hasAvatar
                ? Text(
                    participant.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9D61FF).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Color(0xFF9D61FF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Points Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${participant.points} pts',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}