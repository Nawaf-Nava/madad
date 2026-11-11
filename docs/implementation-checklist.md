# MADAD implementation checklist

## Evidence-backed feature inventory
- [ ] Onboarding and registration/login (strings indicate these flows; layout and exact behavior not yet extracted)
- [ ] Home/dashboard and wallet balance
- [ ] Transactions, details, reports, receipts
- [ ] Transfers: wallet/person, bank, remittance networks, collective transfers
- [ ] Payments and top-ups; QR scan/payment
- [x] Beneficiaries/favorites (local-only demo management)
- [x] Notifications (empty state sheet)
- [ ] Profile and account approval
- [ ] Family/sub-wallets
- [ ] Savings/money box
- [ ] Digital cards
- [ ] Gold
- [ ] Agent/service discovery
- [x] Settings/security toggles (local demo), language/theme informational states
- [ ] Onboarding and registration/login (strings indicate these flows; exact layout and behavior unavailable)

## Verified source facts
- [x] Base APK package `com.ahd.jaib`, version `0.4.9.9` / `499`, min SDK 21, target SDK 36.
- [x] Base manifest requires ABI and density config splits.
- [x] `config.arm64_v8a` and `config.xxhdpi` manifests share package/version code and declare `hasCode=false`.
- [x] ARM64 split has native libraries; density split has resource files.
- [ ] Full screen list, screen hierarchy, exact validation and navigation (JADX provider unavailable; no runtime captures).
- [ ] Native library call graph and endpoint inventory.

## Implementation status
- [x] App shell and MADAD color/spacing/radius tokens
- [x] Main navigation and dashboard
- [x] Transaction empty/filter states
- [x] Transfer form validation and review-only confirmation
- [x] Payment/top-up options and explicit offline demo feedback
- [x] Services catalog, profile, beneficiaries and local security preferences
- [ ] Savings, family wallet, gold, digital card detail screens
- [ ] English localization / runtime language switch
- [x] Original vector MADAD launcher mark and Android splash theme
- [ ] APK build and Android installation/device verification (Gradle dependencies/environment blocker)
