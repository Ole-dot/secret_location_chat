import 'package:flutter_bloc/flutter_bloc.dart';

/// Signals the events bottom sheet to collapse (e.g. after fly-to-target).
class EventsSheetCubit extends Cubit<int> {
  static const double collapsedSize = 0.1;

  EventsSheetCubit() : super(0);

  void requestCollapse() => emit(state + 1);
}
