import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_pm2/app.dart';
import 'package:uts_pm2/providers/history_provider.dart';
import 'package:uts_pm2/providers/quiz_provider.dart';
import 'package:uts_pm2/providers/theme_provider.dart';
import 'package:uts_pm2/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService(await SharedPreferences.getInstance());
  final history = HistoryProvider(storage);
  final theme = ThemeProvider(storage);
  final quiz = QuizProvider(storage: storage, onFinished: history.add);
  await Future.wait([history.load(), theme.load(), quiz.load()]);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: storage),
        ChangeNotifierProvider(create: (_) => history),
        ChangeNotifierProvider(create: (_) => theme),
        ChangeNotifierProvider(create: (_) => quiz),
      ],
      child: const QueryQuestApp(),
    ),
  );
}
