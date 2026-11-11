# MADAD (مَدَد)

Independent Android application reconstruction based on static resources from the Jaib split APK set. The current implementation is a DEMO shell: it never sends financial requests and does not represent a real wallet balance or successful transfer.

## Stack and architecture

Flutter/Dart was selected because Flutter is installed in the environment and the original package includes Flutter/Dart-related runtime markers (including `io.flutter`-style build resources are yet to be confirmed). Presentation is organized by feature under `lib/features`; theme/navigation are in `lib/core`; persistence and demo services belong in `lib/data`.

## Build

```sh
flutter pub get
flutter build apk --debug
```

Android package identifier: `com.madad.wallet`.

## Current known feature inventory from APK resources

Wallet and balance, transfers (wallet/person/bank/remittance), payments/topups, transaction history/reports, notifications, profile, family/sub-wallets, savings money box, digital cards, gold, QR scanning/payment, agent/service discovery, and settings/security. Resource strings establish feature vocabulary only; exact screens and transitions require the unavailable JADX/runtime inspection and are tracked in `docs/implementation-checklist.md`.

## Backend classification

- Local UI navigation/forms/validation/preferences: local.
- Browsing flows and sample transaction rows: DEMO-only, visibly labeled.
- Transfers, payments, account activation, wallet balances, card management, remittance and agent services: require legitimate provider APIs. No success is simulated as a real transaction.
- Login/OTP/KYC: requires an authorized identity service; this demo does not collect credentials or perform authentication.

## Original sources

The three source APKs are treated as one set and remain untouched. Reconstructed UI assets are original MADAD assets; proprietary marks are not copied.
