# WeFin Calculator (weqacalc)

Smart, production-ready financial calculators with personalized Financial Health scoring, usage tracking, and a referral rewards system.

---

## Quick summary
- All hardcoded values removed — calculations use user profile or intelligent fallbacks.
- Financial Health Score computed from real inputs and dynamic calculator-awareness.
- Usage tracking for calculators (UserDataService) persisted with SharedPreferences.
- Referral system with unique codes, local tracking, and reward milestones.
- Code analysis-clean: `dart analyze` returns no issues in current branch.

---

## What's included in this repo
- Multiple calculator screens (investment, loans, retirement).
- Services: `UserDataService`, `ReferralService`, `FinancialHealthService`, `AchievementService`.
- Widgets: financial profile dialog, health card, referral rewards UI, settings.
- Utils: dynamic calculator routing and grid builders.
- Full documentation consolidated into this README (previous top-level MD files were consolidated).

---

## Install & run (development)

Prerequisites: Flutter SDK, Android/iOS tooling.

1. Get dependencies:

```bash
flutter pub get
```

2. Run the app (connected device or emulator):

```bash
flutter run
```

3. Check static analysis:

```bash
dart analyze
```

---

## Project structure (high-level)

lib/
- main.dart — app initialization and service providers
- services/ — `user_data_service.dart`, `referral_service.dart`, `financial_health_service.dart`, etc.
- screens/ — `investment_calculator/`, `loan_calculator/`, `retirement_calculator/`, `financial_calc_home.dart`
- widgets/ — `financial_profile_dialog.dart`, `financial_health_card.dart`, `settings.dart`, `referral_rewards_card.dart`
- utils/ — `calculator_card.dart`, `calculator_grid.dart`, helpers

---

## Core concepts

1. UserDataService
- Central service for: calculator usage tracking, profile persistence (monthly income, savings, debt, emergency fund), and income estimation fallbacks.
- Use `widget.userDataService?.trackCalculatorUsage('calculator_name')` in calculators' `initState` to track usage.

2. Financial Health Score
- Calculated using `FinancialHealthScoreService` with inputs: income (profile or estimated), savings, investments, debts, emergency fund, and number of calculators used.
- Calculators should pass `calculatorsUsed: widget.userDataService?.getTotalCalculatorsUsed() ?? 1` to the calculator helper methods.

3. ReferralService
- Generates and stores a referral code and counts referrals, unlocks rewards at milestones (1, 5, 10, 25).

---

## Calculators (status)

- SIP (Systematic Investment Plan) — integrated with UserDataService and health score.
- EMI (Loan) — integrated and uses EMI-based income estimation when profile missing.
- FIRE / Retirement — integrated to use profile or estimate fallbacks.
- Home Loan, Loan Prepayment, CAGR, Simple Interest — integrated (some added recently).
- Remaining calculators (FD, RD, PPF, EPF, SSY, Compound Interest, Retirement Planning) may need tracking added (small edits).

See the "Action plan" section below for the exact per-file steps.

---

## Action plan — how to add tracking to remaining calculators

For each calculator file:

1. Add import:

```dart
import 'package:weqacalc/services/user_data_service.dart';
```

2. Accept the service in the widget:

```dart
class YourCalculator extends StatefulWidget {
  final UserDataService? userDataService;
  const YourCalculator({super.key, this.userDataService});
}
```

3. Track usage in `initState`:

```dart
widget.userDataService?.trackCalculatorUsage('calculator_name');
```

4. Use dynamic calculator count when computing health score:

```dart
final calculatorsUsed = widget.userDataService?.getTotalCalculatorsUsed() ?? 1;
```

Also update `lib/utils/calculator_card.dart` to create instances that pass `userDataService` when navigating.

Estimated time: ~5 minutes per calculator.

---

## Testing checklist

Manual tests to validate features:

- Financial profile: Settings → Financial Profile → save values → verify calculators use real income.
- Usage tracking: Settings → Calculator Usage Stats; open calculators and verify counts increment.
- Referral system: Settings → Test Referral System → verify referral count and reward unlocks.
- Persistence: Restart app and verify profile, usage, and referrals persist.
- Static analysis: `dart analyze` should report no issues.

---

## Architecture & data flow (brief)

1. App starts and initializes services (`UserDataService`, `ReferralService`, `AchievementService`).
2. Home screen is provided services via `MultiProvider` and passes them into calculators via `calculator_grid` / `calculator_card`.
3. Calculator screens call `userDataService.trackCalculatorUsage()` in `initState` and use profile/estimate values for calculations.
4. `FinancialHealthService` computes a score using persistent data and calculator context.

---

## Notable fixes & linting

- Deprecated Flutter property `activeColor` was addressed in UI where appropriate (use `activeThumbColor`/`activeTrackColor`).
- Null-safety issues: ensure nullable services are invoked safely (e.g., `referralService?.getReferralCount() ?? 0` or assert non-null when safe).
- Avoid `Expanded` inside unbounded parents — use `GridView` with `shrinkWrap: true` or wrap with constrained parent.

---

## Contributing

If you'd like to contribute:

1. Fork and create feature branches.
2. Add `UserDataService` tracking to calculators you update.
3. Run `dart analyze` and ensure no issues.
4. Open a PR with a short description and testing notes.

---

## License

See `LICENSE` at repo root.

---

Generated: November 16, 2025

*** End Patch