import 'package:flutter/material.dart';
import '../screens/financial_calc_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Financial Calculator',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//         brightness: Brightness.light,
//         scaffoldBackgroundColor: Colors.grey.shade50,
//         cardColor: Colors.white,
//       ),
//       // home: const FinancialCalculatorHome(),
//       home: const CalculatorsScreen(),
//     );
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WeFinApp());
}

class WeFinApp extends StatelessWidget {
  const WeFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return MaterialApp(
      title: 'WeFin Calculator',
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
      home: const CalculatorsScreen(),
    );
  }
}
