import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);
  
  bool _isDisposed = false;

  @override
  Future<void> close() {
    _isDisposed = true;
    return super.close();
  }

  void setTab(int index) {
    if (!_isDisposed) {
      emit(index);
    }
  }
}

