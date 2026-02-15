import 'package:fitzee_new/features/auth/data/repositories/account_cleanup_repository_impl.dart';
import 'package:fitzee_new/features/auth/domain/repositories/account_cleanup_repository.dart';
import 'package:fitzee_new/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:fitzee_new/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:fitzee_new/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:fitzee_new/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fitzee_new/features/dashboard/domain/usecases/check_daily_data_usecase.dart';
import 'package:fitzee_new/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:fitzee_new/features/dashboard/presentation/cubit/dashboard_cubit.dart';

/// Dependency injection for the dashboard feature (Clean Architecture).
/// Provides [DashboardCubit] with all use cases; use cases get repositories from here.
/// Keeps construction in one place so UI only receives the cubit.
class DashboardDi {
  static final DashboardRepository _dashboardRepository =
      DashboardRepositoryImpl();
  static final AccountCleanupRepository _accountCleanupRepository =
      AccountCleanupRepositoryImpl();

  static GetDashboardDataUseCase get _getDashboardDataUseCase =>
      GetDashboardDataUseCase(_dashboardRepository);
  static CheckDailyDataUseCase get _checkDailyDataUseCase =>
      CheckDailyDataUseCase(_dashboardRepository);
  static SignOutUseCase get _signOutUseCase =>
      SignOutUseCase(_accountCleanupRepository);
  static DeleteAccountUseCase get _deleteAccountUseCase =>
      DeleteAccountUseCase(_accountCleanupRepository);

  /// Creates a [DashboardCubit] with all dependencies (use cases) injected.
  static DashboardCubit createCubit() => DashboardCubit(
        getDashboardDataUseCase: _getDashboardDataUseCase,
        checkDailyDataUseCase: _checkDailyDataUseCase,
        signOutUseCase: _signOutUseCase,
        deleteAccountUseCase: _deleteAccountUseCase,
      );
}
