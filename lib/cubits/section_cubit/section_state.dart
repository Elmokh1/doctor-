// money_transaction_state_state.dart
import '../../data/model/sections_model.dart';

abstract class SectionState {}

class SectionInitial extends SectionState {}

class SectionLoading extends SectionState {}

class SectionSuccess extends SectionState {}

class SectionLoaded extends SectionState {
  final List<SectionsModel> sections;
  SectionLoaded(this.sections);
}

class SectionError extends SectionState {
  final String message;
  SectionError(this.message);
}
