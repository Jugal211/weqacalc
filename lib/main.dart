import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weqacalc/services/achievement_service.dart';
import 'package:weqacalc/services/referral_service.dart';
import 'package:weqacalc/services/user_data_service.dart';
import '../screens/financial_calc_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final achievementService = AchievementService();
  final referralService = ReferralService();
  final userDataService = UserDataService();
  await achievementService.init();
  await referralService.init();
  await userDataService.init();
  runApp(
    MyApp(
      achievementService: achievementService,
      referralService: referralService,
      userDataService: userDataService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AchievementService achievementService;
  final ReferralService referralService;
  final UserDataService userDataService;

  const MyApp({
    required this.achievementService,
    required this.referralService,
    required this.userDataService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: achievementService),
        Provider.value(value: userDataService),
      ],
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
        home: FinancialCalculatorHome(
          referralService: referralService,
          userDataService: userDataService,
        ),
      ),
    );
  }
}
