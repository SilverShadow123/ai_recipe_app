import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.grey.withAlpha(38)),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/app_icon.svg',
        width: 56,
        height: 56,
      ),
    );
  }
}
