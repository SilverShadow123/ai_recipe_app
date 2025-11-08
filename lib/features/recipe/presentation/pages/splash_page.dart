import 'package:ai_recipe_app/features/recipe/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../bloc/splash/splash_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
          listenWhen: (prev, cur) =>
          prev.isLoggedIn != cur.isLoggedIn ||
              prev.errorMessage != cur.errorMessage,
          listener: (context, state) {
            if (state.isLoggedIn == true) {
              context.goNamed('home');
            } else if (state.isLoggedIn == false) {
              context.goNamed('login');
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          child: BlocBuilder<SplashBloc, SplashState>(
            builder: (context, state) {
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                    SvgPicture.asset('assets/images/app_icon.svg'),
                const Text('AI Recipe Assistant',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Smart Cooking Starts Here', style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),),
                    const SizedBox(width: 8,),
                    Icon(Icons.fastfood_outlined, color: Colors.grey)
                  ],
                ),
CustomLoadingIndicator()
                  ],
                ),
              );
            },
          )
      ),
    );
  }
}
