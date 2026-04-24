# FinPay

FinPay is a **Flutter** demo fintech wallet app: home balance, charts, send money, bills, donations, deposits, notifications, and a full transaction ledger with **receipt-style detail**, **PDF**, and **image** export (via the system share sheet).

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) **3.8+** (see `environment.sdk` in `pubspec.yaml`)
- Xcode (iOS) and/or Android Studio / SDK (Android)

Check your toolchain:

```bash
flutter doctor -v
```

## Project setup

From the repository root:

```bash
cd fintech_app_pro
flutter pub get
```

Run on a device or simulator:

```bash
flutter run
```

Release builds (examples):

```bash
flutter build apk
flutter build ios
```

### Assets & launcher icons

Assets are declared under `flutter: assets:` in `pubspec.yaml`. Launcher icons are configured with `flutter_launcher_icons` (see `pubspec.yaml`). After changing icon config or assets:

```bash
dart run flutter_launcher_icons
```

## Architecture overview

| Area | Location |
|------|----------|
| App entry & theme | `lib/main.dart`, `lib/app.dart`, `lib/theme/` |
| Screens | `lib/screens/` |
| Reusable UI | `lib/widgets/` |
| Models | `lib/models/` |
| Mock / seed data | `lib/data/` |
| Navigation helpers | `lib/navigation/` |
| Utilities (grouping, export) | `lib/utils/` |

The shell after onboarding/login is `MainShell` (`lib/screens/main_shell.dart`), which hosts bottom navigation and feature routes.

## State management: **Provider**

The app uses the official [`provider`](https://pub.dev/packages/provider) package with **`ChangeNotifierProvider`** at the root (`lib/app.dart`).

### Registered providers

1. **`AuthProvider`** (`lib/providers/auth_provider.dart`)  
   Login state, session readiness, logout. The bootstrap flow (`_Bootstrap` in `lib/app.dart`) listens with `Consumer<AuthProvider>` and switches between `LoginScreen` and `MainShell`.

2. **`WalletProvider`** (`lib/providers/wallet_provider.dart`)  
   Balance, payment cards, and the **transaction ledger**. Methods such as `recordSpend`, `recordReceive`, and `addTransaction` mutate internal lists and call `notifyListeners()`. UI uses `context.watch<WalletProvider>()` or `context.read<WalletProvider>()` for one-off actions.

3. **`NotificationsProvider`** (`lib/providers/notifications_provider.dart`)  
   In-app notification feed (mock data); same **ChangeNotifier** pattern.

4. **`UiProvider`** (`lib/providers/ui_provider.dart`)  
   Shell-level UI such as the **drawer / sidebar** open state (`sidebarOpen`, `toggleSidebar`, `closeSidebar`). Bottom navigation uses local state on `MainShell` (`_tab`), not this provider.

### Typical usage in widgets

- **`context.watch<T>()`** — rebuild when `T` notifies (good for lists, balance text).
- **`context.read<T>()`** — get the provider once inside callbacks (e.g. `onPressed`) without subscribing.

Persistence for auth uses **`shared_preferences`** inside `AuthProvider` (see that file for keys and load/save timing).

## Notable features (this codebase)

- **Transaction receipt screen** — `TransactionDetailScreen` uses `TransactionReceiptCard` and `RepaintBoundary` for PNG export (`lib/utils/transaction_export.dart`).
- **PDF export** — Built with the [`pdf`](https://pub.dev/packages/pdf) package, written to a temp file and shared with [`share_plus`](https://pub.dev/packages/share_plus).
- **Transaction history search** — `TransactionHistoryScreen` filters the sorted ledger by title, merchant, reference, notes, channel, amount, and status.
- **Deposit flow** — `DepositScreen` simulates processing, credits the wallet via `WalletProvider.recordReceive`, then pushes `PaymentReceiptScreen` and pops the hosting sheet; errors return to the review step with a `SnackBar`.

## Dependencies (high level)

| Package | Role |
|---------|------|
| `provider` | State management (`ChangeNotifier`) |
| `google_fonts` | Typography |
| `intl` | Dates / formatting |
| `fl_chart` | Home chart |
| `shared_preferences` | Auth / onboarding flags |
| `image_picker` | Profile / flows that pick images |
| `path_provider` | Temp directory for export files |
| `pdf` | PDF receipt generation |
| `share_plus` | OS share sheet for PDF/PNG |

## Troubleshooting

- **`flutter pub get` fails** — align your Flutter/Dart SDK with `pubspec.yaml` (`sdk: ^3.8.1`).
- **Share sheet empty on simulator** — simulators sometimes have limited share targets; test on a real device when validating export.
- **PNG export** — Requires the receipt to be laid out; the export helper waits for a frame before `toImage`.

## License

This project is marked `publish_to: "none"` in `pubspec.yaml` and is intended as a demo / template. Add your own license if you distribute it.
