import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/core/di/injection_container.dart';
import 'package:ptook/features/search_competitions/presentation/cubits/search_competition_cubit.dart';
import 'package:ptook/features/search_competitions/presentation/widgets/competition_card.dart';
import 'package:ptook/features/shared/presintation/widgets/banner_ad_widget.dart';

class MyCompetitionsView extends StatelessWidget {
  final String userId;

  const MyCompetitionsView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFFFD700);

    return BlocProvider<SearchCompetitionCubit>(
      create: (_) => sl<SearchCompetitionCubit>()..fetchCompetitions(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'My Competitions',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: primaryGold),
        ),
        body: SafeArea(
          child: BlocBuilder<SearchCompetitionCubit, SearchCompetitionState>(
            builder: (context, state) {
              if (state is SearchCompetitionLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryGold),
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
                final userCompetitions = state.competitions.where((comp) {
                  return comp.ownerId == userId || comp.isJoinedBy(userId);
                }).toList();

                if (userCompetitions.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have not joined or hosted any competitions yet.',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: userCompetitions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return CompetitionCard(
                      competition: userCompetitions[index],
                      currentUserId: userId,
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }
}