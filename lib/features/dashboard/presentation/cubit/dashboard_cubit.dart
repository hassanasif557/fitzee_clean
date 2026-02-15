import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitzee_new/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:fitzee_new/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fitzee_new/features/dashboard/domain/usecases/check_daily_data_usecase.dart';
import 'package:fitzee_new/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';

import 'dashboard_state.dart';

/// Cubit for the dashboard screen (Bloc/Cubit state management).
/// Depends only on use cases (Clean Architecture); no direct service calls.
/// Handles: loading dashboard data, daily data prompt, refresh, sign-out, delete account.
class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final CheckDailyDataUseCase checkDailyDataUseCase;
  final SignOutUseCase signOutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  DashboardCubit({
    required this.getDashboardDataUseCase,
    required this.checkDailyDataUseCase,
    required this.signOutUseCase,
    required this.deleteAccountUseCase,
  }) : super(const DashboardState());

  /// Checks if user has yesterday's daily data; if not, sets [needsDailyDataCollection].
  /// Otherwise loads full dashboard data. Called on init and when returning from daily data screen.
  Future<void> checkDailyDataAndLoad() async {
    if (isClosed) return;
    try {
      final hasYesterday = await checkDailyDataUseCase();
      if (!hasYesterday) {
        if (!isClosed) {
          emit(state.copyWith(
            needsDailyDataCollection: true,
            isLoading: false,
          ));
        }
        return;
      }
      await load();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Loads dashboard data: fast path first (formula score, no meal plan), then AI in background.
  Future<void> load() async {
    if (isClosed) return;
    if (!isClosed) {
      emit(state.copyWith(
        isLoading: true,
        isLoadingAI: false,
        errorMessage: null,
        needsDailyDataCollection: false,
      ));
    }

    try {
      final data = await getDashboardDataUseCase();
      if (isClosed) return;
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          isLoadingAI: true,
          userProfile: data.userProfile,
          healthScore: data.healthScore,
          dailyData: data.dailyData,
          todayNutrition: data.todayNutrition,
          todayMedicalEntries: data.todayMedicalEntries,
          workoutPlan: data.workoutPlan,
          todayWorkout: data.todayWorkout,
          workoutStreak: data.workoutStreak,
          dailyMealPlan: data.dailyMealPlan,
        ));
      }

      // Load AI meal plan in background (health score stays formula-based)
      getDashboardDataUseCase.getAIData().then((aiResult) {
        if (isClosed) return;
        if (!isClosed) {
          emit(state.copyWith(
            dailyMealPlan: aiResult.dailyMealPlan ?? state.dailyMealPlan,
            isLoadingAI: false,
          ));
        }
      }).catchError((e) {
        if (!isClosed) {
          emit(state.copyWith(isLoadingAI: false));
        }
      });
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> refresh() => load();

  /// Clears the "need daily data collection" flag (e.g. after user dismisses or completes the flow).
  void clearDailyDataCollectionFlag() {
    if (isClosed) return;
    if (state.needsDailyDataCollection && !isClosed) {
      emit(state.copyWith(needsDailyDataCollection: false));
    }
  }

  /// Signs out the user via [SignOutUseCase] and emits [signOutSuccess] for UI to navigate.
  /// Call from UI (e.g. nav panel); do not call Firebase Auth directly in the UI.
  Future<void> signOut() async {
    if (isClosed) return;
    try {
      await signOutUseCase();
      if (!isClosed) {
        emit(state.copyWith(signOutSuccess: true, authError: null));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(authError: e.toString()));
      }
    }
  }

  /// Deletes the current Firebase account: cloud data first (while authenticated), then Auth user, then local cleanup.
  /// Firestore delete must happen before [user.delete()] or security rules reject it (user no longer authenticated).
  Future<void> deleteAccount() async {
    if (isClosed) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!isClosed) {
        emit(state.copyWith(authError: 'No account to delete. Sign in first.'));
      }
      return;
    }
    final userId = user.uid;
    try {
      // 1. Delete Firestore profile and FCM token while still authenticated (required for Firestore rules).
      await deleteAccountUseCase(userId);
      // 2. Delete Firebase Auth user.
      await user.delete();
      // 3. Local cleanup (sign out, clear storage).
      await signOutUseCase();
      if (!isClosed) {
        emit(state.copyWith(deleteAccountSuccess: true, authError: null));
      }
    } on FirebaseAuthException catch (e) {
      if (!isClosed) {
        if (e.code == 'requires-recent-login') {
          // Auto sign out and redirect so user can sign in again to delete; no manual sign-out needed.
          await signOutUseCase();
          emit(state.copyWith(
            signOutSuccess: true,
            authError: 'Signed out for security. Sign in again to delete your account.',
          ));
        } else {
          emit(state.copyWith(authError: e.message ?? 'Failed to delete account.'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(authError: 'Error: ${e.toString()}'));
      }
    }
  }
}
