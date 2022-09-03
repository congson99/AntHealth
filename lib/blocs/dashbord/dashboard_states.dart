import 'package:anthealth_mobile/blocs/app_states.dart';
import 'package:anthealth_mobile/models/dashboard/dashboard_models.dart';
import 'package:anthealth_mobile/models/family/family_models.dart';
import 'package:anthealth_mobile/models/post/post_models.dart';

class HomeState extends CubitState {
  HomeState(this.events, this.posts);

  final List<dynamic> events;
  final List<Post> posts;

  @override
  List<Object> get props => [events, posts];
}

class HealthState extends CubitState {
  HealthState(this.healthPageData);

  final HealthPageData healthPageData;

  @override
  List<Object> get props => [healthPageData];
}

class MedicState extends CubitState {
  MedicState(this.medicPageData);

  final MedicPageData medicPageData;

  @override
  List<Object> get props => [medicPageData];
}

class FamilyState extends CubitState {
  FamilyState(this.members);

  final List<FamilyMemberData> members;

  @override
  List<Object> get props => [members];
}

class SettingsState extends CubitState {
  @override
  List<Object> get props => [];
}

class DoctorLoadingState extends CubitState {
  DoctorLoadingState();

  @override
  List<Object> get props => [];
}

class HomeLoadingState extends CubitState {
  @override
  List<Object> get props => [];
}

class HealthLoadingState extends CubitState {
  @override
  List<Object> get props => [];
}

class MedicLoadingState extends CubitState {
  @override
  List<Object> get props => [];
}

class FamilyLoadingState extends CubitState {
  @override
  List<Object> get props => [];
}

class SettingsLoadingState extends CubitState {
  @override
  List<Object> get props => [];
}
