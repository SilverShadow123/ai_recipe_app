import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bottom_nav_state.dart';


class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);

  void setTab(int index) => emit(index);
}

