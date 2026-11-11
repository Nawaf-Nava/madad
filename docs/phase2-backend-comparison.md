# Phase 2 — Jaib static backend indicators vs MADAD current system

## Evidence limitation

Jaib APK static analysis found client-side Room/Room-generated database classes, a `Resource` network result class, beneficiary/favorite sync workers, Firebase messaging integration, a first-party application shell, and UI strings covering sign-in, wallet/account activation, transfers, payments/top-up, remittances, family wallets, savings, digital cards, gold, gifts, donations, beneficiaries, branches, notifications and receipts. Its Android manifest disables cleartext traffic and app backup and declares network/authentication-related platform permissions.

This does **not** establish Jaib's server stack, remote database, API URLs/schemas, hashing/session policy, ledger semantics, provider contracts or settlement behavior. No Jaib server was contacted and no credential/key/native-store values were inspected. Those unknowns are not inferred from UI text.

MADAD repository source was inspected. PostgreSQL 16 service is active and `pg_isready` says it accepts TCP/socket connections, but the current Unix account has no PostgreSQL role (`psql` reports role `nawaf` does not exist), `sudo -n -u postgres` requires a password, no backend `.env` exists, and no existing MADAD DB role/owner can be verified without administrative credentials. Therefore no real MADAD database query, migration, signup or backend listener was run in this phase.

## Comparison

| Area | Jaib static evidence | MADAD before Phase 2 | Change performed / current boundary |
|---|---|---|---|
| Registration | Sign-in/activation/password labels; exact server flow unknown | Express register existed; UI previously bypassed it and opened Home | Auth screen now posts real registration data through `AuthRepository`; backend creates User/Profile/empty Wallet/session atomically and returns tokens. |
| Login | Online/offline, biometric/password UI labels; server protocol unknown | Login route existed; UI bypassed it | UI now calls `/api/auth/login`; invalid credentials/errors stay on auth page; successful response gates Home. |
| Session/logout | Session protocol unknown; login/account switch strings | Access/refresh JWTs, `UserSession` persisted raw refresh token; no refresh/logout routes | Refresh tokens now stored as SHA-256 digests, refresh rotates/revokes prior DB session, access tokens bind to persisted session ID, logout and logout-all routes added. Legacy raw tokens can rotate once, then are replaced with a digest. |
| User/profile | Client profile/account-switching labels | Protected profile GET existed; Flutter did not call it | Added owner-scoped PATCH for name/email; Profile screen fetches server data, displays load/error states, edits fields through API, and calls server/local logout. |
| Wallets/accounts | Wallet/account/activation/approval labels | Prisma Wallet relation and owner-filtered list existed; UI showed fabricated values | Registration creates an empty, zero-balance wallet record only. UI fetches current-user wallets; no funding or account activation is asserted. Added owner-scoped wallet detail GET. |
| Transactions | Receipt/report/payment/transfer string vocabulary | Model and owner-filtered list existed; no UI API integration | Dashboard and transaction tab fetch the authenticated user's existing rows and show loading/error/empty states. No create/success endpoint was added. |
| Transfers/payments | Transfer modes, Wasil, collective, remittance and payment-QR vocabulary; settlement semantics unknown | Transfer API already returned provider-required 503; no provider credentials configured | Existing transfer 503 preserved; payments now explicitly return `503 FINANCIAL_PROVIDER_UNAVAILABLE`. UI does not claim transactions succeeded. |
| Other service families | Strings for remittance, family, savings, card, gold, gifts, donations, agents, notifications | Most screens were presentation-only | No provider or financial CRUD endpoint was fabricated. These services remain unavailable until official provider contracts/credentials are supplied. |
| Data model/migrations | Jaib local Room class is visible; remote schema unknown | Prisma models and an initial migration exist locally | Added additive nullable owner relations/indexes for legacy TransferRequest/Bill. Migration is nondestructive in SQL, but not applied because DB existence/schema/backup state is unverified. |
| API/client | Network result type exists; endpoint details unknown | Express auth/wallet routes; Flutter data folder was empty at inspection | Added HTTP client for only existing/new MADAD routes, secure token storage, one-shot refresh-and-retry, app auth state, and platform-specific local development base URL. |
| Security | Manifest cleartext and backup disabled; server controls unknown | Bcrypt/JWT middleware; no rate limit, generic CORS, secrets require env | Added Helmet, auth rate limit, production fail-closed CORS, JSON size cap, safe error responses, HS256-only JWT verification, input checks, session revocation and audit actions. HTTPS still must be provided at deployment/reverse-proxy boundary. |

## Database ownership changes

The new migration `20261111_user_owned_records` only adds nullable `userId` columns to `TransferRequest` and `Bill`, indexes them, and adds `ON DELETE SET NULL` foreign keys. Existing rows are preserved with null owner, rather than deleting or guessing ownership. New application code does not create these rows until an explicitly authorized service operation is implemented.

The existing schema already associates UserProfile, Wallet, Transaction, Beneficiary, SavingsGoal, Gift sender/receiver, Notification, Device, UserSession and AuditLog with users. AppSetting remains intentionally global. No database was dropped/recreated and no existing user data was touched.

## Real-provider availability

No provider keys, official remittance/payment/card/gold/donation/agent/support contract, sandbox endpoint, or settlement webhooks were present in the inspected project. Accordingly these paths were not activated. Transfers and payments remain 503. Jaib strings do not supply a legally authorized provider contract.
