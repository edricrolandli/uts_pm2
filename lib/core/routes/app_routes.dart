import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_tokens.dart';
import '../../screens/home_screen.dart';
import '../../screens/pending_screen.dart';
import '../../screens/quiz_screen.dart';

abstract final class AppRoutes {
  static const home = '/home';
  static const quiz = '/quiz';
  static const result = '/result';
  static const review = '/review';
  static const history = '/history';
  static const initial = home;

  static Route<void> onGenerateRoute(
    RouteSettings settings,
  ) => PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: AppTokens.durMedium,
    reverseTransitionDuration: AppTokens.durMedium,
    pageBuilder: (context, animation, secondaryAnimation) {
      void backHome() =>
          Navigator.of(context).popUntil(ModalRoute.withName(home));
      return switch (settings.name) {
        quiz => const QuizScreen(),
        result => PendingScreen(title: AppStrings.result, onReturn: backHome),
        review => PendingScreen(title: AppStrings.review, onReturn: backHome),
        history => PendingScreen(
          title: AppStrings.historyTitle,
          onReturn: backHome,
        ),
        _ => HomeScreen(
          onOpenQuiz: () => Navigator.of(context).pushNamed(quiz),
          onOpenHistory: () => Navigator.of(context).pushNamed(history),
        ),
      };
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        MediaQuery.disableAnimationsOf(context)
        ? child
        : FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: AppTokens.curveStandard),
            ),
            child: child,
          ),
  );
}
