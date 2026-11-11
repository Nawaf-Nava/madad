# Jaib backend/service analysis — static artifact scope

## Evidence boundary

The supplied artifact is the split set `base.apk`, `split_config.arm64_v8a.apk`, and `split_config.xxhdpi.apk`; package metadata previously inspected through JADX MCP reports `com.ahd.jaib`, version `0.4.9.9` / code `499`, min SDK 21, target SDK 36. A verified JADX headless MCP 0.7.1 process loaded `base.apk` and reported 11,619 classes and 5,239 resources. The current REA MCP Android provider itself is not configured in-session (`REA_JADX_MCP_JAR` is missing), so these are direct local JADX MCP observations, not REA Evidence.

This review is static only. Jaib was not installed or run; no Jaib credentials, native key values, API credentials, endpoint payloads, or server traffic were recovered. No Jaib server was contacted. Obfuscation and absence of runtime access limit conclusions. Resource strings and class names identify vocabulary/components, not completed server behavior.

## Observed server/data-related structure

The first-party class inventory includes:

- `com.ahd.jaib.data.db.JaibRoomDatabase` and its generated implementation, establishing a Room database client component. The tables, columns, retention policy, and server/database schema were not recovered in this UI-focused analysis.
- `com.ahd.jaib.data.network.Resource`, establishing a named network-result abstraction. It does not by itself reveal API URLs, request/response contracts, retry behavior, or server state machine.
- `com.ahd.jaib.services.SyncBeneficiariesWorker`, `SyncBeneficiaryWorker`, and `SyncFavoritesWorker`, establishing background synchronization worker classes for beneficiary/favorite domains. Their exact synchronization contract and conflict policy remain unknown.
- `com.ahd.jaib.services.JaibFirebaseService`, and manifest declarations for Firebase messaging / measurement / Crashlytics components. This shows messaging-related client plumbing, not that any specific notification reached a user or how backend notification records are stored.
- `com.ahd.jaib.NativeStore` exposes native getter method names for app/auth/initialization/POS configuration. Getter names are not endpoint or credential evidence. Their values were deliberately not read.

## Feature domains visible in localized strings / first-party metadata

- **Registration/authentication:** sign-in, online-login-required, offline-mode, password change/reset, fingerprint/biometric sign-in, account switching/removal, account activation and approval terms.
- **Profiles/accounts:** client profile, wallet/account number, wallet status, account activation/approval, family-wallet identity fields.
- **Wallet/transfer:** transfer between wallets/accounts, recipient/person, bank/wallet, Wasil/other wallet, collective transfer, beneficiary suggestions, transfer cancellation/receipt conditions.
- **Payments/top-ups:** top-up, government and NMF payment labels, payment gateway/service payments, merchant POS QR and payment-code expiry messages.
- **Remittance networks:** local/global remittance, Hazmi, Wenet, Jaib remittance, transfer state, recipient identity matching, branch selection.
- **Digital card / online card:** create/link, activate/block, edit, color selection, reload, statement, empty transaction state.
- **Family / savings:** family-wallet creation, services/limits, cash-in/out, empty family state, Hasalah savings goal, automatic saving and fractional saving descriptions.
- **Gold:** 21-karat label, balance, buy/sell/withdraw, delivery-agent branch label, empty transaction state.
- **Gifts/donations:** Hadiah send/request/empty-state terms; donation organization selection and validation.
- **Branches/notifications/receipts:** branch/agent refresh/selection/error, empty notification state, transaction receipt/save/export terms.

These domains do not establish which records are server-authoritative, which calls mutate external systems, or the exact status transitions.

## Observable platform/security configuration

- Manifest launch activity: `MainActivity`; four localized top-level entries are initialized in its static method output as top-up, wallet, remittance, purchases.
- Manifest sets `android:usesCleartextTraffic="false"`, disables Android backup (`allowBackup="false"`), supports RTL and declares network-state/internet, contact, camera, biometric, notification and storage permissions among others.
- MainActivity class output calls Firebase messaging APIs and initializes a four-item section list. A QRScannerActivity is declared separately and static code shows Compose/CameraX-related camera UI plus an image-import callback.
- The artifact's signature inspection only reads declared signing records/self-consistency; it did not cryptographically verify signatures or publisher authenticity.

## What cannot be inferred here

| Question | Status | Why |
|---|---|---|
| Jaib API base URL, endpoint paths, schemas, auth protocol | Unknown | Not recovered in the static UI pass; no traffic was captured and no server was contacted. |
| Server platform, database engine/schema/relationships | Unknown | Room client class name does not reveal the remote database. Local Room schema was not enumerated here. |
| Access/refresh token lifespan, session revocation, password hashing server-side | Unknown | UI strings and class names do not prove server implementation. |
| Wallet ledger, settlement, idempotency, external-provider reconciliation | Unknown | No backend or authorized integration evidence inspected. |
| Exact service operations, authorization flow, fees, success/failure transitions | Unknown/partial labels only | Strings describe user-facing concepts, not verified execution. |
| Full screen list, layouts, visual design, transitions, loading/error states | Incomplete | No Android device/emulator, screenshots, runtime navigation, or complete Compose NavHost recovery. |

## Comparison summary

| Area | Jaib static evidence | MADAD current implementation before Phase 2 | Phase 2 action |
|---|---|---|---|
| Registration/sign-in | Sign-in, passwords, biometrics, offline/login messages | UI unconditionally navigated home; backend routes already existed | Connect UI to actual auth API; no demo bypass. |
| User/profile | Client profile and profile switching labels | Profile route existed; backend `/profile` existed but UI unused | Add authenticated profile read/update and correct per-user scoping. |
| Wallet/accounts | Wallet/account/activation and sub-wallet labels | Prisma Wallet model and read route; UI screens used local labels/data | Use existing wallet read API; initial wallet remains zero by schema and is not spendable proof. |
| Transactions | Receipt, statement, transfer/payment vocabulary | Transaction model/read route; app displayed empty/static UI | Read actual authenticated user's transactions; no write/financial success endpoint. |
| Services | Many external or provider-dependent labels | Mostly static/preview forms | Do not invent endpoints. Keep provider-dependent operations unavailable. |
| Database | Jaib local Room class only; server DB unknown | PostgreSQL Prisma schema/migration exists; DB auth blocked from current user | Preserve schema/migration, no destructive or speculative schema edits. |
| API/network | Network result class, Firebase and worker names; no endpoint contract | Express health/auth/wallet routes; Flutter had no extant client at inspection time | Add client integration only for current routes; no reverse-engineered proprietary service calls. |
| Security | Backup disabled, cleartext disabled, biometric/contact/camera permissions | JWT middleware, bcrypt, refresh session table; refresh token persisted as raw JWT | Hash stored refresh-token values, rotate/revoke sessions, rate limit auth and validate inputs. |

The full backend behavior of Jaib is intentionally not claimed. A later authorized server/API contract or owner-provided sandbox is needed before implementing any financial integration.
