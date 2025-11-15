import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weqacalc/services/achievement_service.dart';
import 'package:weqacalc/services/referral_service.dart';
import '../screens/financial_calc_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final achievementService = AchievementService();
  final referralService = ReferralService();
  await achievementService.init();
  await referralService.init();
  runApp(
    MyApp(
      achievementService: achievementService,
      referralService: referralService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AchievementService achievementService;
  final ReferralService referralService;

  const MyApp({
    required this.achievementService,
    required this.referralService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: achievementService)],
      child: MaterialApp(
        title: 'Financial Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey.shade50,
          cardColor: Colors.white,
        ),
        home: FinancialCalculatorHome(referralService: referralService),
      ),
    );
  }
}
