# MADAD UI comparison and phase-1 implementation ledger

This ledger compares the 18 current feature-level Flutter screens with the static evidence in [jaib-analysis.md](jaib-analysis.md). Jaib's exact rendered page count and visual hierarchy are not recovered because no Android device/emulator was available and its Compose navigation is partly obfuscated. Therefore “mapped” means feature-vocabulary/flow alignment, not pixel parity.

| MADAD screen | Jaib evidence match | Current MADAD state before this phase | UI implementation target / boundary |
|---|---|---|---|
| Auth | Sign-in, offline/online, biometric/password, account switching strings | Branded form, but Arabic-only text and continue button bypasses any auth result | Shared title/input/button styling; bilingual RTL/LTR; make demo/connection boundaries explicit. No auth/backend changes. |
| Home | Four Jaib shell sections (top-up, wallet, remittance, purchases); wallet and service labels | Branded dashboard, but hard-coded nav and only 4 quick actions | Consistent shell/service catalog links, orange icon tiles, no fake balance. Exact Jaib home composition unknown. |
| Transactions | Receipt, statement export, notification-empty strings | Filter chips and static empty state | Reusable empty/loading/error-ready visual states; retain no-data state until available data exists. |
| Services | Jaib labels for payments/top-ups, transfers, remittances, family, cards, gifts, savings, gold, donations, branches | 12-entry list; some labels and entries are reconstructed rather than verified | Categorized visual catalogue, searchable/filterable only if local UI; mark unsupported actions clearly. No new endpoints. |
| Transfers | Wallet/bank/person/other-wallet, collective and network transfer labels | Form and review sheet; bright cream banner inconsistent with dark theme | Dark notice and consistent form/summary card; keep confirmation explicitly non-executing. |
| Payments | Top-up/payment, government/NMF, payment QR, POS QR, expiry strings | Radio service choice and modal, no camera integration | Consistent service cards and provider-unavailable states; no simulated completion. |
| Profile | Profile/switch profiles/remove account strings | Partial profile list; mostly Arabic, language control exists | Use shared row/tile patterns and localized labels; preserve navigation. |
| Account tools | Beneficiaries, fingerprint/password, settings strings | Beneficiary local list, demo security toggles, settings text currently claims light theme | Dark shared sections, truthful local-only/status text, use existing locale switch; no credential storage. |
| Notifications | Empty notification title/message and FCM component | Two hard-coded messages claim security updates/welcome | Remove fabricated messages in favor of a clearly empty/unavailable state, styled for dark mode. No push integration. |
| Chat | No visual screen evidence retrieved | Local echo and delayed canned reply | Label as local preview or empty/unavailable; dark conversation surfaces; no claim that support received a message. |
| Donations | Organization picker and required-selection strings | Hard-coded organizations, totals and progress; button says donation recorded in demo | Replace implied live campaign figures with unavailable/preview UI and provider-required notice; don't record success. |
| Entertainment | No specific product/category evidence retrieved beyond purchase/card vocabulary | Hard-coded vendors and prices | Present as unavailable/preview catalogue only; remove price promises unsupported by evidence. |
| Branches | Branch/agent selection and refresh/error strings; locations permission in manifest | Hard-coded branch addresses and phone numbers; map action says a location was set | Clearly distinguish sample locations or empty unavailable list; no false map action. |
| Digital card | Create/link/activate/block/color/reload/statement strings | Fabricated masked card number, cardholder and expiry; lock toggle and snackbar | Remove fabricated credential-like card details; use an unavailable card placeholder and non-success UI. |
| Hadiah | Gift/no-gift/request strings | Local preview form and dialog | Keep form visually coherent; say preview only, no transfer or “sent” semantics. |
| Hasalah | Savings goal, auto-save, fractions to goal strings | Two fabricated goals and balances, add-goal defaults to a numeric amount | No real funds shown; display no data until provided, retain only clearly local goal UI if explicit. |
| Remittance | Hazmi/Wenet/Jaib/local-network labels and mismatch requirements | Hard-coded network list and result modal says record not found | Provider-unavailable query state; don't claim a real network lookup was performed. |
| Sub-wallets | Family wallet, empty-family, services/limits, cash-in/out strings | Two fabricated wallets/balances and action snackbar says operation succeeded | Remove false balances/success wording, show unavailable/empty state until a source exists. |

## Shared components to standardize

- App shell: MADAD brand mark, consistent app-bar title/leading/trailing controls, four-slot destination navigation.
- Page header: title + one-line explanatory subtitle + optional leading orange icon.
- Service/category row and compact quick-action tile.
- Dark cards, orange icon badge, consistent 20/16/14 dp radii and 4/8/16/24/32 dp spacing.
- Empty state (icon, title, explanation, optional safe action); informational/unavailable notice; loading placeholder and recoverable error presentation.
- Confirmation dialog/bottom sheet uses Material dark theme; review-only actions use explicit “not executed” copy.
- Locale-aware text and directional icons/padding. Arabic remains default; English should naturally lay out LTR.

## Screen inventory/status

Existing MADAD Dart feature files: 18 screen widgets (Auth, Home, Transactions, Services, Transfers, Payments, Profile, Account Tools, Notifications, Chat, Branches, Card, Donations, Entertainment, Hadiah, Hasalah, Remittance, Sub-wallets). Jaib evidence suggests all these broad service families except that chat/entertainment as dedicated screen designs are not confirmed; conversely Jaib has additional substates (activation/approval, reports/receipts, QR camera/import, profile switching, password/biometrics, branch refresh, digital-card statements, Wasil/collective flows) that MADAD does not yet expose as separate evidenced pages.

This ledger is UI-only. It does not specify or add backend endpoints. Any live balances, transactions, recipient lookups, branch data, card operations, donations, remittance, or support delivery require a legitimate future data provider.
