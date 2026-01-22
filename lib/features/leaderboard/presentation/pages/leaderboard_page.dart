import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitzee_new/core/constants/app_colors.dart';
import 'package:fitzee_new/core/services/local_storage_service.dart';
import 'package:fitzee_new/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:fitzee_new/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:fitzee_new/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:fitzee_new/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:fitzee_new/features/leaderboard/domain/usecases/get_user_entry_usecase.dart';
import 'package:fitzee_new/features/leaderboard/presentation/cubit/leaderboard_cubit.dart';
import 'package:fitzee_new/features/leaderboard/presentation/cubit/leaderboard_state.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final remoteDataSource = LeaderboardRemoteDataSource();
        final repository = LeaderboardRepositoryImpl(remoteDataSource);
        final getLeaderboardUseCase = GetLeaderboardUseCase(repository);
        final getUserEntryUseCase = GetUserEntryUseCase(repository);

        final cubit = LeaderboardCubit(
          getLeaderboardUseCase: getLeaderboardUseCase,
          getUserEntryUseCase: getUserEntryUseCase,
        );

        // Load initial data
        cubit.loadLeaderboard();

        return cubit;
      },
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkBlueGreen,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDarkLight,
        elevation: 0,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: () {
              context.read<LeaderboardCubit>().refresh();
            },
          ),
        ],
      ),
      body: BlocBuilder<LeaderboardCubit, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          if (state is LeaderboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardCubit>().refresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textBlack,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LeaderboardLoaded) {
            return Column(
              children: [
                // Filter and Period Selector
                _buildFilterSection(context, state),
                const SizedBox(height: 16),
                // Current User Card (if available)
                if (state.currentUserEntry != null)
                  _buildCurrentUserCard(context, state.currentUserEntry!),
                const SizedBox(height: 16),
                // Leaderboard List
                Expanded(
                  child: state.entries.isEmpty
                      ? _buildEmptyState()
                      : _buildLeaderboardList(context, state.entries),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, LeaderboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundDarkLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          const Text(
            'Time Period',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPeriodChip(
                  context,
                  'Week',
                  LeaderboardPeriod.week,
                  state.currentPeriod,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPeriodChip(
                  context,
                  'Month',
                  LeaderboardPeriod.month,
                  state.currentPeriod,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPeriodChip(
                  context,
                  'All Time',
                  LeaderboardPeriod.allTime,
                  state.currentPeriod,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Selector
          const Text(
            'Rank By',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'Health Score',
                  LeaderboardFilter.healthScore,
                  state.currentFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Health Improvement',
                  LeaderboardFilter.healthImprovement,
                  state.currentFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Nutrition',
                  LeaderboardFilter.nutritionScore,
                  state.currentFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Nutrition Improvement',
                  LeaderboardFilter.nutritionImprovement,
                  state.currentFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Total Improvement',
                  LeaderboardFilter.totalImprovement,
                  state.currentFilter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    String label,
    LeaderboardPeriod period,
    LeaderboardPeriod currentPeriod,
  ) {
    final isSelected = period == currentPeriod;
    return GestureDetector(
      onTap: () {
        context.read<LeaderboardCubit>().changePeriod(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.backgroundDarkBlueGreen,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.textGray.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.textBlack : AppColors.textWhite,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    LeaderboardFilter filter,
    LeaderboardFilter currentFilter,
  ) {
    final isSelected = filter == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<LeaderboardCubit>().changeFilter(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.backgroundDarkBlueGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.textGray.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textBlack : AppColors.textWhite,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserCard(BuildContext context, LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName ?? 'You',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Health: ${entry.healthScore} | Nutrition: ${entry.nutritionScore}',
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Improvement
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    entry.healthScoreImprovement >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: entry.healthScoreImprovement >= 0
                        ? AppColors.primaryGreen
                        : AppColors.errorRed,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.healthScoreImprovement >= 0 ? '+' : ''}${entry.healthScoreImprovement}',
                    style: TextStyle(
                      color: entry.healthScoreImprovement >= 0
                          ? AppColors.primaryGreen
                          : AppColors.errorRed,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    List<LeaderboardEntry> entries,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardItem(context, entry, index);
      },
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardEntry entry,
    int index,
  ) {
    // Top 3 get special styling
    final isTopThree = entry.rank <= 3;
    final rankColors = [
      AppColors.warningYellow, // Gold
      AppColors.textGray, // Silver
      Color(0xFFCD7F32), // Bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkLight,
        borderRadius: BorderRadius.circular(16),
        border: isTopThree
            ? Border.all(
                color: rankColors[entry.rank - 1],
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isTopThree
                  ? rankColors[entry.rank - 1]
                  : AppColors.backgroundDarkBlueGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  color: isTopThree
                      ? AppColors.textBlack
                      : AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName ?? 'User ${entry.userId.substring(0, 6)}',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMetricChip('Health', entry.healthScore),
                    const SizedBox(width: 8),
                    _buildMetricChip('Nutrition', entry.nutritionScore),
                  ],
                ),
                if (entry.healthScoreImprovement != 0 ||
                    entry.nutritionScoreImprovement != 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (entry.healthScoreImprovement != 0)
                        _buildImprovementChip(
                          'Health',
                          entry.healthScoreImprovement,
                        ),
                      if (entry.nutritionScoreImprovement != 0) ...[
                        const SizedBox(width: 8),
                        _buildImprovementChip(
                          'Nutrition',
                          entry.nutritionScoreImprovement,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatItem(Icons.directions_walk, '${entry.averageSteps}'),
              const SizedBox(height: 4),
              _buildStatItem(
                Icons.local_fire_department,
                '${entry.averageCalories}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildImprovementChip(String label, int improvement) {
    final isPositive = improvement >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.primaryGreen.withOpacity(0.2)
            : AppColors.errorRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: isPositive ? AppColors.primaryGreen : AppColors.errorRed,
          ),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}$improvement',
            style: TextStyle(
              color: isPositive ? AppColors.primaryGreen : AppColors.errorRed,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textGray),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.leaderboard_outlined,
            color: AppColors.textGray,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Leaderboard Data',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
          ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your health to appear on the leaderboard!',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
