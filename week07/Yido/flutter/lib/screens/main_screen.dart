import 'package:flutter/material.dart';
import 'package:movielog/widgets/movies/movie_navigation_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.location, required this.child});
  final String location;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: MovieNavigationBar(location: location),
  );
}
