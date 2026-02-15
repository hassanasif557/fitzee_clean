part of 'onboard_cubit.dart';

sealed class OnboardState extends Equatable {
  const OnboardState();

  @override
  List<Object> get props => [];
}

final class OnboardInitial extends OnboardState {}

final class OnboardGoalSelected extends OnboardState {
  final String goal;

  const OnboardGoalSelected(this.goal);

  @override
  List<Object> get props => [goal];
}

final class OnboardHeightSet extends OnboardState {
  final double height;

  const OnboardHeightSet(this.height);

  @override
  List<Object> get props => [height];
}

final class OnboardWeightSet extends OnboardState {
  final double weight;

  const OnboardWeightSet(this.weight);

  @override
  List<Object> get props => [weight];
}

final class OnboardGenderSet extends OnboardState {
  final String gender;

  const OnboardGenderSet(this.gender);

  @override
  List<Object> get props => [gender];
}

final class OnboardAgeSet extends OnboardState {
  final int age;

  const OnboardAgeSet(this.age);

  @override
  List<Object> get props => [age];
}

final class OnboardNameSet extends OnboardState {
  final String name;

  const OnboardNameSet(this.name);

  @override
  List<Object> get props => [name];
}

final class OnboardPhoneSet extends OnboardState {
  final String phone;

  const OnboardPhoneSet(this.phone);

  @override
  List<Object> get props => [phone];
}

final class OnboardExerciseFrequencySet extends OnboardState {
  final int frequency;

  const OnboardExerciseFrequencySet(this.frequency);

  @override
  List<Object> get props => [frequency];
}

final class OnboardTrainingDaysSet extends OnboardState {
  final int days;

  const OnboardTrainingDaysSet(this.days);

  @override
  List<Object> get props => [days];
}

final class OnboardPreferredTimeSet extends OnboardState {
  final String timeOfDay;

  const OnboardPreferredTimeSet(this.timeOfDay);

  @override
  List<Object> get props => [timeOfDay];
}

final class OnboardSleepHoursSet extends OnboardState {
  final double hours;

  const OnboardSleepHoursSet(this.hours);

  @override
  List<Object> get props => [hours];
}

final class OnboardStressLevelSet extends OnboardState {
  final int level;

  const OnboardStressLevelSet(this.level);

  @override
  List<Object> get props => [level];
}

final class OnboardMedicalConditionSet extends OnboardState {}

final class OnboardMedicalProfileSet extends OnboardState {}

final class OnboardPhysicalStateSet extends OnboardState {}

final class OnboardRecentEventsSet extends OnboardState {}

final class OnboardSaving extends OnboardState {}

final class OnboardCompleted extends OnboardState {}

final class OnboardError extends OnboardState {
  final String message;

  const OnboardError(this.message);

  @override
  List<Object> get props => [message];
}
