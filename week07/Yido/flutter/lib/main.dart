import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movielog/app/movie_log_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp 전에 .env 로드를 끝내야 Token을 빈 값으로 읽지 않는다
  await dotenv.load(fileName: '.env');
  runApp(const MovieLogApp());
}
