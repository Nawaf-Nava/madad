# Jaib UI/UX Analysis (static artifact review)

## Scope and evidence boundary

This document records only evidence gathered from the supplied Jaib APK set. The artifact is a three-file Android split set: `base.apk`, `split_config.arm64_v8a.apk`, and `split_config.xxhdpi.apk`. The base package metadata returned by the verified JADX MCP 0.7.1 process was `com.ahd.jaib`, version `0.4.9.9` / code `499`, min SDK 21, target SDK 36. It loaded 11,619 classes and 5,239 resources; APK size was 28,467,162 bytes. Earlier signature inspection found the arm64 split is native-library focused and the xxhdpi split supplies density assets; treat them as one install set, not separate apps.

The local JADX MCP JAR at `/home/nawaf/.local/share/rea/jadx-headless-mcp-0.7.1-all.jar` was run directly over stdio after checking the publisher's SHA-256 (`6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75`). It identified itself as version 0.7.1, exposed 27 tools, loaded the base APK, returned app info/manifest/strings/resource inventory, and decompiled selected first-party classes. REA's Android operation itself is **not configured in the current REA MCP process**: calls to `inspect_android_package` and `inspect_android_class` return `capability_unavailable` requesting `REA_JADX_MCP_JAR`. Therefore JADX results below are direct MCP protocol evidence, not REA Evidence.

`adb devices -l` returned no connected devices. No emulator/system image was shown available. The original Jaib package was **not installed or launched**. No screenshot, live navigation capture, animation recording, or interaction test was possible. Consequently, this is a substantial static UI inventory, not a complete visual/runtime audit. R8/obfuscation and Compose-generated UI also prevent a complete screen census from names alone. Unknowns are explicitly marked below.

No Jaib account credentials, network endpoints, key material, native-store values, or other application secrets were requested or extracted. No Jaib service was contacted.

## Static application shell

- Manifest launcher: `com.ahd.jaib.MainActivity`, portrait orientation, `singleTop`, with configuration changes for orientation, keyboard-hidden, and locale; soft input uses resize.
- Application class: `com.ahd.jaib.base.JaibApp`.
- The first-party `MainActivity.onCreate` code creates four main tab/navigation entries whose localized labels are top-up, wallet, remittance, and purchases. The output associates the remittance tab with an icon named `ic_transfer_to_person`. This establishes a four-section top-level shell, but not the complete nested route graph.
- Manifest activity `com.ahd.jaib.QRScannerActivity` is not exported. Static decompilation shows a Compose-hosted camera UI, camera permission state, and an image-import callback. Strings also evidence separate messages for scanning Jaib/merchant QR codes and permission rationale.
- Manifest also declares `LivePhotoCaptureActivity` (portrait) and common crop-image activity. Their exact user journeys were not reconstructed.
- Manifest and labels indicate RTL support and a locale setting. Arabic and English strings exist. Locale-specific screenshot/rendering was unavailable.

## Screen and flow inventory

The inventory distinguishes a **screen family evidenced by resources/first-party metadata** from an independently verified rendered screen. A label or empty-state string can establish a feature/state but cannot by itself prove its exact placement, layout, or navigation transition.

| Screen / family | Evidence and observed UI content | Interactions/states evidenced | Confidence / gaps |
|---|---|---|---|
| Main shell / home | `MainActivity`; four top-level entries: top-up, wallet, remittance, purchases. `home`/الرئيسية string is present. | Tab selection implied by four navigation entries. | Shell labels and count are source-backed; screenshots, selected-tab appearance, nested home contents, and transition animation not observed. |
| Sign-in / account entry | Strings include sign-in, sign-in-again, login-network dialog, online/offline login requirement, fingerprint sign-in. | Sign-in, error retry, offline SMS mode, biometric/password fallback are evidenced by strings. | Exact form layout, ordering, validation, OTP sequence, and offline transition are not verified. |
| Wallet overview / activation | Wallet, wallet status/account, activate wallet, approval/incomplete approval, disable/cancel wallet, account number and unapproved-wallet notices. | Wallet activation/approval, status, account selection, and unavailable/unapproved messages are evidenced. | Exact card design, balance typography, toggles, action arrangement, and account-state transition are unknown. |
| Transfer hub | Strings identify wallet-to-wallet, bank/wallet, transfer to person/subscriber, other wallets/Wasil, transfer between accounts, collective transfers, and remittance-network transfers. | Source labels include same-wallet/account validation; Wasil receipt/cancellation conditions include a five-day validity window. | Transfer modes and selected validation concepts are evidenced; exact wizard steps, confirmations, inputs, fee/error states, and route edges are not complete. |
| Remittance | Strings identify local/global remittance, Hazmi, Wenet, Jaib remittance, network transfer state, and agent/branch concepts. | Recipient-name/phone matching and transfer-origin restrictions are described in resources. | No live provider interaction; exact network picker, receipt/search steps, loading/errors, and screen count are unknown. |
| Top-up and payments | Top-up & payment services, NMF, government payments, bill/service payments, reminders, payment gateway, Wasil number. | Invalid payment number, choose-service/organization validation, payment QR expiry, payment QR and merchant QR messages. | Payment categories are evidenced; no provider was called and exact forms, merchant confirmation, success/failure, and loading visuals are not verified. |
| QR camera / payment scanner | `QRScannerActivity`; Compose, CameraX/ML Kit barcode dependency metadata, camera permission strings, import-image callback. | Camera permission prompt/rationale, scan Jaib or POS QR, and image import are evidenced. | Camera preview, overlay/torch controls, swipe behavior, scan result/dialog, and denial/retry visual states were not run. |
| Purchases / internet cards | `purchases` top-level label; strings for internet/Wi-Fi cards and card choice/reload. | Card selection and reload concepts are evidenced. | Exact catalogue/list/detail UI and purchase interaction states unknown. |
| Digital cards | Strings for create/link, activate/block, edit, color selection, reload amount, card statement, and empty transactions. | Create/link/edit/block/reload/delete confirmation and empty-statement state are evidenced by strings. | Exact card illustration, colors, input steps, confirmations and errors were not visually observed. No actions executed. |
| Family / sub-wallets | “Jaib Family”, no-family-wallet empty state, add family wallet, services & limits, cash-in/out, temporary password. | Create, customize permissions/limits, cash-in/out, and empty state evidenced. | Exact number of pages, participant/member view, layout, and gestures unknown. |
| Savings / Hasalah | Hasalah goal planning; automatic savings; fractional amounts transferred to goal. | Savings goal and auto-save concepts evidenced. | Goal creation, progress visualization, schedules, empty/error states not recovered visually. |
| Gold | Gold balance, buy, sell, 21 karat, withdrawal and YKB branch delivery. | Buy/sell/withdraw and branch location are labels; empty gold transactions message exists. | No gold data/service accessed; exact price card, chart, filters, and confirmation flow unknown. |
| Donations | Donation organization picker and invalid-organization validation. | Select an organization before proceeding. | Exact list, organization branding, amount entry, dialogs, empty/error UI not verified. |
| Beneficiaries / suggestions | Empty list, search, beneficiary, confirm-delete-all, deletion-success strings. | Search, suggested beneficiary selection, delete-all confirmation. | Exact page boundaries, add/edit forms, gesture actions and navigation unknown. |
| Favorites | `SyncFavoritesWorker` in first-party class inventory; favorite-related labels occur in resources. | Background synchronization class is present; exact visible operations not inferred from that alone. | No specific favorites screen layout or route confirmed. |
| Transactions / receipts / statements | Receipt, transaction receipt, export/report and receipt-save strings; notification channel named `Transactions`. | Save/share receipt, statement export, date range and empty-history concepts evidenced by strings. | Exact transaction filters, details, timeline, receipt view, report controls and empty/error/loading designs unknown. |
| Notifications | `JAIB_UNREAD_NOTIFICATIONS` and Firebase messaging service; explicit empty notifications title/message. | Notification empty state and delivery component evidence. | No notification list was rendered; mark-read, navigation, grouping, and push interactions not tested. |
| Profile / account switch | `profile`, client profile, switch profiles, remove account from this device. | Switch account and remove local account confirmation are evidenced. | Exact profile details, avatar, controls, ordering, and menu/modal presentation not verified. |
| Security / passwords / biometrics | Fingerprint sign-in, enable fingerprint confirmation, password change/reset, set/use password strings. | Fingerprint/password alternatives, password-length rules, mismatch, reset/change success/error text. | No biometric prompt or password flow run; secure UI dimensions and system dialogs not captured. |
| Agent branches / locations | Agent branch, branch selection, refresh branches, invalid branch ID, Hazmi/YKB branch references. | Refresh and choose-branch validation evidenced. | Map/list implementation, location permissions, markers, empty/loading/error layouts not visually tested. |
| Help / permission / generic dialogs | Camera, contacts, storage permission rationale strings; payment/QR and biometric messages. | Permission rationale/settings guidance and several validation/error states are evidenced. | Exact dialog component/theme, dismissal gesture, and every error state unavailable. |

### Navigation map (only statically established links)

```text
MainActivity
├── Top-up tab → Top-up/payment service family
├── Wallet tab → Wallet, approval/activation, wallet-related account tasks
├── Remittance tab → Local/global networks, Hazmi/Wenet/Jaib labels
└── Purchases tab → Internet-card/purchase labels

Other evidenced entry points (exact parent and route order unknown)
├── QRScannerActivity → camera permission → scan UI → import image callback
├── Wallet transfer choices → wallet/person/bank/other-wallet/collective flows
├── Family wallet → create → service/limit customization → cash-in/out
├── Digital card → create/link → edit/activate/block/reload/statement
└── Profile/account → profile switch/remove; password/biometric settings
```

This map is a set of evidence-backed feature relations, **not** a complete recovered navigation graph. Only the four top-level MainActivity item labels and QR scanner activity boundary are directly tied to app-shell/activity evidence; other edges are feature-family relationships inferred from strings and should be validated against runtime or decompiled navigation host code.

## Visual/design system evidence

### Confirmed artifact facts

- The application theme is referenced as `@style/Theme.Jaib`; the app requests RTL support and includes a locale configuration.
- The base APK contains 12 font files: `circle_rounded_{thin,extra_light,light,regular,bold,extra_bold}.otf` and `linaround_{thin,extra_light,light,regular,semi_bold,bold}.otf`.
- The base APK has 854 `res/drawable` members, 118 night drawable variants, 24 animation resources, 6 animator resources, 25 color resources, 40 ordinary layout XML resources and additional library layouts. Layout names are overwhelmingly AndroidX/cropper/system component layouts, so their count is **not** evidence of 40 app screens.
- The density split has 47 drawable members including `drawable-ldrtl-xxhdpi`; it contains density-specific visual assets. The base has launcher mipmaps and 986 drawable-related resources in JADX's complete inventory. Filenames include generated/icon resources; no image-by-image visual catalogue was produced.
- Animation resource names include generic support fade/slide/popups, fragment open/close/fade transitions, and checkbox/radio transitions. These are packaged animations; no proof that every resource is used by a Jaib screen or that they define app-level Compose transitions.

### Not reliably recovered

- Exact brand/background/surface/primary color hex values, typography scale, font assignment per component, spacing/radius/elevation/shadow tokens, and density-specific icon appearance were **not** established. `get_resource_file`/decompiled theme rendering was not completed; no screenshots exist.
- Individual icons, photos, illustrations, and image assets were not visually reviewed. A file name or drawable count is insufficient to identify its screen usage.
- Bottom sheets, dialogs, swipes, scroll behavior, loading spinners/skeletons, transition durations, error color treatment, and touch target sizes were not captured in a running app.

## Split handling and fingerprints

The three artifacts were considered as one set. Static signature inspection previously reported the same declared signer certificate fingerprint across base and both config splits, and package metadata from the app inventory is `com.ahd.jaib`. Signing inspection does not authenticate the publisher; it only reports declared signing records and self-consistency. SHA-256 identities from the prior verified signature result:

- Base: `5f3365f87aa410ec35b186ed1e75a5276a5893dc9156bd5ae052c188b172cfbc`
- ARM64: `3239bfa88474c896fa1e5dad73cb1cee2ee309c87762696b474fe92a71dc066f`
- XXHDPI: `3d2d1f4b1a98157039447e7d6a6407f9ee0538249d66177975959504c790c005`

## Coverage and open questions

| Area | Status | Reason / required evidence |
|---|---|---|
| Package identity, launcher, manifest components, app class count, permission vocabulary | Static coverage obtained | JADX MCP app info/manifest/class inventory. |
| Feature names, Arabic/English UI strings, key validation and empty-state copy | Partial static coverage | String resource searches are not a complete screen census and do not establish presentation. |
| Four top-level sections | Directly evidenced | MainActivity source initializes four localized navigation entries. |
| All individual screen layouts and order | Incomplete | App uses Compose and much of its code is obfuscated; full NavHost/Compose route reconstruction has not been completed. |
| Activities/Fragments inventory | Partial | Launcher, QR scanner and live photo capture identified. A full exported/component-to-screen map was not built; many manifest components are libraries. |
| Visual comparison / screenshots | Not performed | `adb devices -l` had no devices, and no emulator/system image was available. |
| Real taps, swipes, navigation, keyboard, dialogs and animation timing | Not performed | No target installation or runtime session was started. |
| Backend/API contract | Out of scope and not analyzed | This document is UI/UX-only. No API extraction or server interaction was attempted. |
| REA Android operation | Blocked in current session | REA MCP reports the JADX provider unavailable because `REA_JADX_MCP_JAR` is not set in its process. The verified JADX MCP JAR was invoked directly as a separate local MCP process. |

A complete visual parity claim must wait for runtime screenshots and interaction recording (real device or a properly installed emulator), plus additional decompilation of the Compose navigation host and screen-specific composables. No missing detail in this report should be treated as a design fact.
