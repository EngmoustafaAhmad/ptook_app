import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/shared/domain/entities/competition_entity.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_cubit.dart';
import 'package:ptook/features/view_competition/presintation/cubits/competition_home_state.dart';
import 'package:ptook/features/view_competition/presintation/pages/competition_details_view.dart' hide AppColors;

class SavedCompetitionsView extends StatefulWidget {
  final String userId;

  const SavedCompetitionsView({
    super.key,
    required this.userId,
  });

  @override
  State<SavedCompetitionsView> createState() => _SavedCompetitionsViewState();
}

class _SavedCompetitionsViewState extends State<SavedCompetitionsView> {
  @override
  void initState() {
    super.initState();
    context.read<CompetitionHomeCubit>().fetchSavedCompetitions(
          userId: widget.userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.amber, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
             Navigator.pop(context);
           }
        ),
        title: const Text(
          'Saved Competitions',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: BlocConsumer<CompetitionHomeCubit, CompetitionHomeState>(
        listener: (context, state) {
          if (state is CompetitionHomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is CompetitionHomeActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CompetitionHomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (state is SavedCompetitionsLoaded) {
            if (state.competitions.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              color: Colors.amber,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                await context
                    .read<CompetitionHomeCubit>()
                    .fetchSavedCompetitions(userId: widget.userId);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.competitions.length,
                itemBuilder: (context, index) {
                  final competition = state.competitions[index];

                  return _SavedCompetitionCard(
                    competition: competition,
                    isFavorite: true,
                    participantCount: competition.participantsCount,
                    onToggleFavorite: () {
                      context.read<CompetitionHomeCubit>().toggleFavorite(
                            userId: widget.userId,
                            competition: competition,
                          );
                    },
                    onTap: () {
                      // Navigate to competition detail page
                    },
                  );
                },
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.bookmark_remove_outlined,
              size: 48,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Saved Competitions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore competitions and tap the bookmark\nicon to save them here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCompetitionCard extends StatefulWidget {
  final CompetitionEntity competition;
  final bool isFavorite;
  final int participantCount;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _SavedCompetitionCard({
    required this.competition,
    required this.isFavorite,
    required this.participantCount,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  State<_SavedCompetitionCard> createState() => _SavedCompetitionCardState();
}

class _SavedCompetitionCardState extends State<_SavedCompetitionCard> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant _SavedCompetitionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFav = widget.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.competition.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _isFav
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFav = !_isFav;
                    });
                    widget.onToggleFavorite();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.competition.description,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined,
                    color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${widget.participantCount} Participants',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> CompetitionDetailsView(competition: widget.competition)));
                  },
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.amber, size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}