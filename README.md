
# WeFin Calculator (weqacalc)

WeFin Calculator is a Flutter app that bundles a set of financial calculators (investments, loans, retirement) with:

- A personalized Financial Health Score computed from profile or usage data.
- Per-calculator usage tracking persisted via `SharedPreferences` (`UserDataService`).
- A local referral/rewards system (`ReferralService`) with shareable codes and milestone rewards.

This README is an authoritative summary of the codebase, how to run it, architecture notes, and where to make small feature additions.

---

## Quick start

Prerequisites: Flutter SDK (matching project's channel) and platform tooling.

1. Install dependencies:

```powershell
flutter pub get
```

2. Run on a connected device or emulator:

```powershell
flutter run
```

3. Verify static analysis:

```powershell
dart analyze
```

---

## High-level layout

Key folders and files:

- `lib/main.dart` — app bootstrap and service providers.
- `lib/services/` — core services: `user_data_service.dart`, `financial_health_service.dart`, `referral_service.dart`, `achievement_service.dart`.
- `lib/screens/` — grouped calculators (investment, loan, retirement, home) and `financial_calc_home.dart`.
- `lib/widgets/` — shared widgets: profile dialog, health card, referral UI, settings, etc.
- `lib/utils/` — `calculator_card.dart`, `calculator_grid.dart` and helpers used by the home grid.

---

## Core services (brief)

- UserDataService
  - Persists user profile: monthly income, savings, debt, and emergency fund flag.
  - Tracks calculator usage counts and total calculations performed.
  - Provides `estimateMonthlyIncome()` fallback when profile is missing.

- FinancialHealthService
  - Computes a numeric score and category (e.g., Healthy, Needs Attention) using profile, debts, savings, and calculators used.
  - Factory helpers available for calculator-specific scoring (SIP, EMI, loan prepayment, fixed investments).

- ReferralService
  - Generates a referral code, persists counts locally, and exposes reward milestones and unlocked rewards.

---

## How calculators use services

- Home grid (`lib/utils/calculator_grid.dart`) passes `UserDataService` and other services into calculator widgets.
- Each calculator should accept `UserDataService? userDataService` and call `widget.userDataService?.trackCalculatorUsage('name')` in `initState`.
- When computing health score, pass `calculatorsUsed: widget.userDataService?.getTotalCalculatorsUsed() ?? 1` to the `FinancialHealthService` helpers.

Small code template to add to a calculator widget:

```dart
class ExampleCalc extends StatefulWidget {
  final UserDataService? userDataService;
  const ExampleCalc({super.key, this.userDataService});
}

@override
void initState() {
  super.initState();
  widget.userDataService?.trackCalculatorUsage('example_calc');
}
```

---

## UI/Linting patterns and recent fixes

- Avoid placing `Expanded` around a `GridView` inside an unbounded parent. Use `GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` for grids inside scrolling columns.
- Use `Text( ..., overflow: TextOverflow.ellipsis)` or wrap text in `Expanded` to prevent `Row` overflow.
- Replace deprecated `Switch.activeColor` with `activeThumbColor` / `activeTrackColor` where applicable.

These fixes were applied to `lib/widgets/achievement_badge.dart`, `lib/utils/calculator_grid.dart`, and `lib/widgets/financial_profile_dialog.dart`.

---

## Remaining small tasks (low effort)

- Add `UserDataService` tracking to these calculators if you want complete coverage: FD, RD, PPF, EPF, SSY, Compound Interest, Retirement Planning. Each is ~5 minutes.

---

## Testing & verification

Manual tests:

- Save a financial profile (Settings → Financial Profile) and verify calculators use real income.
- Open calculators and verify `UserDataService` counters increment (Settings or debug UI exposes counts).
- Use referral UI to generate/share a code and mark referrals; verify reward unlocks.

Static tests:

- `dart analyze` — should return no issues on the active branch.

Optional: run unit tests if present with `flutter test`.

---

## Contributing

- Follow standard GitHub workflow: branch, commit, PR.
- Run `dart analyze` before opening PRs.
- Keep UI behavior consistent with small device constraints (avoid unbounded `Expanded` usage).

---

## License

See the `LICENSE` file in the repository root.

---

Generated from project sources on November 16, 2025.

*** End Patch