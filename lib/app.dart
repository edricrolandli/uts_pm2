import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uts_pm2/core/responsive/responsive.dart';
import 'package:uts_pm2/core/theme/app_theme.dart';
import 'package:uts_pm2/core/theme/quiz_colors.dart';
import 'package:uts_pm2/providers/theme_provider.dart';

class QueryQuestApp extends StatelessWidget {
  const QueryQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueryQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: context.watch<ThemeProvider>().mode,
      home: const _PlaceholderScreen(),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final qc = context.quizColors;
    return Scaffold(
      appBar: AppBar(title: const Text('QueryQuest')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.r.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nunito Regular', style: text.titleLarge),
            Text(
              'Nunito ExtraBold',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: context.r.sm),
            Text(
              'SELECT * FROM mahasiswa;',
              style: text.bodyLarge?.copyWith(fontFamily: 'JetBrainsMono'),
            ),
            SizedBox(height: context.r.md),
            Container(
              padding: EdgeInsets.all(context.r.md),
              color: qc.correctContainer,
              child: Text('Benar', style: TextStyle(color: qc.correct)),
            ),
            SizedBox(height: context.r.sm),
            Container(
              padding: EdgeInsets.all(context.r.md),
              color: qc.wrongContainer,
              child: Text('Salah', style: TextStyle(color: qc.wrong)),
            ),
          ],
        ),
      ),
    );
  }
}
