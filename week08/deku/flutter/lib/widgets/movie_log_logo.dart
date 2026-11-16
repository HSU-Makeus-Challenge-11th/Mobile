import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';

class MovieLogLogo extends StatelessWidget {
  const MovieLogLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.movieLogLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: 'MovieLog 로고',
    );
  }
}
