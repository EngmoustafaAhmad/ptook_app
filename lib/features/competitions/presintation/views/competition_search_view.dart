import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/extentions/spacing_extentions.dart';
import 'package:ptook/features/competitions/domain/entities/competition_entity.dart';
import 'package:ptook/features/competitions/presintation/bloc/search_competition_cubit.dart';
import 'package:ptook/features/competitions/presintation/views/competition_details_view.dart';
import 'package:ptook/features/competitions/presintation/widgets/competition_card.dart';

class CompetitionSearchView extends StatefulWidget {
  const CompetitionSearchView({super.key});

  @override
  State<CompetitionSearchView> createState() => _CompetitionSearchViewState();
}

class _CompetitionSearchViewState extends State<CompetitionSearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    final keyword = value.trim();

    if (keyword.isEmpty) {
      context.read<SearchCompetitionCubit>().clearSearch();
      return;
    }

    context.read<SearchCompetitionCubit>().search(keyword);
  }

  /// Navigates to details and listens for the updated CompetitionEntity on return
  Future<void> _navigateToDetails(
    BuildContext context,
    CompetitionEntity competition,
  ) async {
    // 🎯 Only pass the competition entity
    final updatedCompetition = await Navigator.push<CompetitionEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailsView(
          competition: competition,
        ),
      ),
    );

    // If the competition was modified (joined/left), update local memory list!
    if (updatedCompetition != null && context.mounted) {
      context
          .read<SearchCompetitionCubit>()
          .updateCompetitionInList(updatedCompetition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Search Competitions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search public competitions",
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(.5),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            20.vs,
            Expanded(
              child: BlocBuilder<SearchCompetitionCubit, SearchCompetitionState>(
                builder: (context, state) {
                  if (state is SearchCompetitionInitial) {
                    return Center(
                      child: Text(
                        "Search for competitions",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.5),
                        ),
                      ),
                    );
                  }

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
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is SearchCompetitionSuccess) {
                    if (state.competitions.isEmpty) {
                      return Center(
                        child: Text(
                          "No competitions found",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.5),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.competitions.length,
                      separatorBuilder: (_, __) => 12.vs,
                      itemBuilder: (context, index) {
                        final competition = state.competitions[index];

                        final isOwner = currentUserId != null &&
                            currentUserId == competition.ownerId;
                        final isJoined = competition.isJoinedBy(currentUserId);

                        return GestureDetector(
                          onTap: () => _navigateToDetails(
                            context,
                            competition,
                          ),
                          child: CompetitionCard(
                            competition: competition,
                            isOwner: isOwner,
                            isJoined: isJoined,
                          ),
                        );
                      },
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
}