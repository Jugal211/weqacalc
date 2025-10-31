# WeFin Calculator - Your All-in-One Financial Calculator

WeFin Calculator is a comprehensive Flutter-based financial calculator application designed to help users manage their finances effectively. It provides various calculators for investments, loans, and retirement planning, all within a user-friendly interface.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)
- [To-Do](#to-do)
- [Privacy Policy](#privacy-policy)

## Features

- **Investment Calculator**: Plan your investments with detailed calculations for returns, compound interest, and more.
- **Loan Calculator**: Understand your loan repayments, interest, and amortization schedules.
- **Retirement Calculator**: Estimate your retirement savings and plan for a secure future.
- **User-Friendly Interface**: Clean and intuitive design for easy navigation and input.
- **Cross-Platform**: Built with Flutter, supporting Android, iOS, Web, Windows, macOS, and Linux.

## Screenshots

<!-- Add screenshots of your application here. Example: -->

| Home Screen | Investment Calculator | Loan Calculator | Retirement Calculator |
|-------------|-----------------------|-----------------|-----------------------|
| ![Home Screen](assets/screenshots/home_screen.png) | ![Investment Calculator](assets/screenshots/investment_calculator.png) | ![Loan Calculator](assets/screenshots/loan_calculator.png) | ![Retirement Calculator](assets/screenshots/retirement_calculator.png) |

## Installation

To get a local copy up and running, follow these simple steps.

### Prerequisites

Make sure you have Flutter installed. If not, follow the official Flutter installation guide: [Flutter Get Started](https://flutter.dev/docs/get-started/install)

### Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Jugal211/weqacalc.git
    cd weqacalc
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```

## Usage

-   Navigate through the different calculator sections using the bottom navigation bar or the app drawer.
-   Enter your financial details into the respective fields.
-   View instant calculations and results.

## Project Structure

```
.
├── lib/
│   ├── main.dart             # Main entry point of the application
│   ├── models/               # Data models for calculations
│   │   └── calculator_item.dart
│   ├── screens/              # UI for different calculator screens
│   │   ├── coming_soon_screen.dart
│   │   ├── financial_calc_home.dart
│   │   ├── investment_calculator/
│   │   │   ├── cagr_calc.dart
│   │   │   ├── compound_interest_calc.dart
│   │   │   ├── epf_calc.dart
│   │   │   ├── fd_calc.dart
│   │   │   ├── ppf_calc.dart
│   │   │   ├── rd_calc.dart
│   │   │   ├── simple_interest_calc.dart
│   │   │   ├── sip_calc.dart
│   │   │   └── ssy_calc.dart
│   │   ├── loan_calculator/
│   │   │   ├── emi_calc.dart
│   │   │   ├── home_loan_calc.dart
│   │   │   └── loan_prepay_calc.dart
│   │   └── retirement_calculator/
│   │       ├── fire_calc.dart
│   │       └── retirement_calc.dart
│   ├── utils/                # Utility functions and custom widgets
│   │   ├── calculator_card.dart
│   │   ├── calculator_grid.dart
│   │   └── utils.dart
│   └── widgets/              # Reusable widgets
│       ├── about.dart
│       └── settings.dart
└── pubspec.yaml              # Project dependencies and metadata
└── README.md                 # Project documentation
└── PRIVACY_POLICY.md         # Privacy Policy document
└── LICENSE                   # Project License
```

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## To-Do

- [ ] Add more financial calculators (e.g., mortgage, savings)
- [ ] Implement user accounts to save calculations
- [ ] Add charts and graphs for better visualization
- [ ] Improve UI/UX and add animations
- [ ] Add localization for multiple languages

## Privacy Policy

We are committed to protecting your privacy. Please read our [Privacy Policy](PRIVACY_POLICY.md) to understand how we handle your data.

---

Project Link: [https://github.com/Jugal211/weqacalc](https://github.com/Jugal211/weqacalc)


