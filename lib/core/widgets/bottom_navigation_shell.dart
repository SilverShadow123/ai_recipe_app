import 'package:ai_recipe_app/features/recipe/presentation/bloc/bottom_navigation/bottom_nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationShell extends StatelessWidget {
  final Widget child;
  const BottomNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(builder: (_, index){
      return Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i){
            context.read<BottomNavCubit>().setTab(i);
            switch(i){
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/saved');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          }, items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.save_alt),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    });
  }
}
